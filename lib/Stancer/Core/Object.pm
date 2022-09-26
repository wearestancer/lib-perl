package Stancer::Core::Object;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Basic API object
# VERSION

use Stancer::Core::Types qw(coerce_datetime ArrayRef Bool Char HashRef InstanceOf Maybe Str);

use Carp;
use Stancer::Config;
use Stancer::Core::Request;
use List::MoreUtils qw(any first_index one);
use Log::Any qw($log);
use JSON;
use Scalar::Util qw(blessed);
use Storable qw(dclone);

use Moo;
use namespace::clean;

=head1 DESCRIPTION

You should not use this class directly.

This module is an internal class, regouping method for every API object.

=method C<< Stancer::Core::Object->new() : I<self> >>

=method C<< Stancer::Core::Object->new(I<$token>) : I<self> >>

=method C<< Stancer::Core::Object->new(I<%args>) : I<self> >>

=method C<< Stancer::Core::Object->new(I<\%args>) : I<self> >>

This method accept an optional string, it will be used as an entity ID for API calls.

=cut

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;

    if (scalar @args == 1 && !ref $args[0]) {
        return { id => $args[0] } if defined $args[0];
        return {};
    }

    my $data;

    if (ref $args[0] eq 'HASH') {
        $data = $args[0];
    } else {
        $data = {@args};
    }

    foreach my $key (keys %{$data}) {
        delete $data->{$key} unless defined $data->{$key};
    }

    return $class->$orig($data);
};

=for Pod::Coverage BUILD

=for comment Not supposed to be public, but protected is not possible.
We let it in "public area" but without documentation.
We use hydratation to force modified list to be accurate on new instance.

=cut

sub BUILD {
    my ($this, $args) = @_;

    # Force modified list
    for my $key (keys %{$args}) {
        $this->_add_modified($key) if $key ne 'id' && $key ne 'created';
    }

    return $this;
}

has _api_data => (
    is => 'rw',
    isa => HashRef,
);

=begin comment

Inner callback call before accessing a property to make a populate call before.

=end comment

=cut

sub _attribute_builder {
    my ($this, $attr) = @_;
    my $has = 'has_' . $attr;

    if ($this->populate()->$has()){
        return $this->$attr;
    }

    return;
}

=begin comment

List of property that must be transtyped in boolean in JSON export.

=end comment

=cut

has _boolean => (
    is => 'ro',
    isa => ArrayRef[Str],
    default => sub{ [] },
);

=begin comment

List of property where DateTime should be concidered as a date only.

=end comment

=cut

has _date_only => (
    is => 'ro',
    isa => ArrayRef[Str],
    default => sub{ [] },
);

=begin comment

List of property with object inside.

Used to propagate modification on modified properties list.

=end comment

=cut

has _inner_objects => (
    is => 'ro',
    isa => ArrayRef[Str],
    default => sub{ [] },
);

=begin comment

List of property that must be transtyped in integer in JSON export.

=end comment

=cut

has _integer => (
    is => 'ro',
    isa => ArrayRef[Str],
    default => sub{ [] },
);

=begin comment

List of property that must be ignored in JSON export.

=end comment

=cut

has _json_ignore => (
    is => 'ro',
    isa => ArrayRef[Str],
    default => sub{ [qw(endpoint created populated)] },
);

=begin comment

Read/Write arrayref of string.

Indicate if the current object has been modified.

Use with care.

=end comment

=cut

has _modified => (
    is => 'rwp',
    isa => ArrayRef[Str],
    default => sub{ [] },
);

sub _add_modified {
    my ($this, $name) = @_;

    $this->_set__modified([]) unless defined $this->_modified; # I don't know why but I sometimes get undef

    push @{$this->_modified}, $name unless one { $_ eq $name } @{$this->_modified};

    return $this;
}

sub _reset_modified { ## no critic (RequireFinalReturn)
    my $this = shift;

    $this->_set__modified([]);

    for my $attr (@{$this->_inner_objects}) {
        $this->$attr->_reset_modified() if defined $this->$attr;
    }
}

=begin comment

Read/Write boolean.

Indicate if we are currently in an hydratation.

=end comment

=cut

has _process_hydratation => (
    is => 'rwp',
    isa => Bool,
    default => 0,
    writer => '_set_process_hydratation',
);

=attr C<id>

Read-only 29 characters string.

Current object identifier.

=cut

has id => (
    is => 'rwp',
    isa => Char[29],
    clearer => 1,
    predicate => 1,
);

=attr C<created>

Read-only instance of C<DateTime>.

A DateTime object representing the creation date.

Value is only present for object returned by the API, so the method can return C<undef>.

=cut

has created => (
    is => 'rwp',
    isa => Maybe[InstanceOf['DateTime']],
    builder => sub { $_[0]->_attribute_builder('created') },
    coerce  => coerce_datetime(),
    lazy => 1,
    predicate => 1,
);

=attr C<endpoint>

Read-only string.

API endpoint.

=cut

has endpoint => (
    is => 'ro',
    isa => Str,
    default => q//,
);

=attr C<is_modified>

=attr C<is_not_modified>

Read/Write boolean.

Indicate if the current object is modified or not.

=cut

sub is_modified {
    my $this = shift;
    my $is_modified = scalar @{$this->_modified} > 0;

    return $is_modified if $is_modified;

    for my $attr (@{$this->_inner_objects}) {
        return 1 if defined $this->$attr && $this->$attr->is_modified;
    }

    return !1;
}

sub is_not_modified {
    my $this = shift;

    return !$this->is_modified;
}

=attr C<populated>

Read-only boolean.

Indicate if the current object has been populated from API data.

=cut

has populated => (
    is => 'rwp',
    isa => Bool,
    default => 0,
    writer => '_set__populated',
);

sub _set_populated {
    my ($this, $value) = @_;

    $this->_set__populated($value);

    for my $attr (@{$this->_inner_objects}) {
        $this->$attr->_set_populated($value) if defined $this->$attr;
    }

    return $this;
}

=attr C<uri>

Read-only String.

Return a complete location for the current object.

=cut

sub uri {
    my $this = shift;
    my $config = Stancer::Config->init();
    my @args = (
        $config->uri,
    );

    if ($this->endpoint) {
        push @args, $this->endpoint;
    }

    if ($this->id) {
        push @args, $this->id;
    }

    return join q!/!, @args;
}

=method C<< $obj->del() : I<self> >>

Delete the current object.

=cut

sub del {
    my $this = shift;

    return $this unless defined $this->id;

    my $data = Stancer::Core::Request->new->del($this);

    if ($data) {
        $this->hydrate(decode_json $data);
    }

    my @parts = split m/::/sm, ref $this;
    my $class = $parts[-1];

    $log->info(sprintf '%s %s deleted', $class, $this->id);

    $this->clear_id;

    return $this;
}

=method C<< $obj->get() : I<hash> | I<undef> >>

=method C<< $obj->get( I<$attr> ) : I<mixed> >>

Return raw data from the API.

C<$attr> must be a string, keys should be an object property.

=cut

sub get {
    my ($this, $target) = @_;

    return unless defined $this->_api_data;
    return dclone($this->_api_data) unless defined $target;

    my $data = $this->_api_data->{$target};

    return dclone($data) if ref $data ne q//;
    return $data;
}

=method C<< $obj->hydrate( \%data ) : I<self> >>

=method C<< $obj->hydrate( %data ) : I<self> >>

Hydrate the current object.

C<%data> must be an hash or a hashref, keys should be an object property.

=cut

sub hydrate {
    my ($this, @args) = @_;
    my $data;

    if (scalar @args == 1) {
        $data = $args[0];
    } else {
        $data = {@args};
    }

    $this->_set_process_hydratation(1);

    foreach my $key (keys %{$data}) {
        next if not defined $data->{$key};

        my $setter = '_set_' . $key;

        if (JSON::is_bool($data->{$key})) {
            my $tmp = $data->{$key};

            $data->{$key} = "$tmp";
            $data->{$key} = 1 if "$tmp" eq 'true';
            $data->{$key} = 0 if "$tmp" eq 'false';
        }

        if ($this->can($key) && blessed($this->$key) && $this->$key->can('hydrate')) {
            if (ref $data->{$key} eq 'HASH') {
                $this->$key->hydrate($data->{$key});
            } else {
                $this->$key->hydrate(id => $data->{$key});
            }
        } elsif ($this->can($setter)) {
            $this->$setter($data->{$key});
        } elsif ($this->can($key)) {
            $this->$key($data->{$key});
        }
    }

    $this->_set_process_hydratation(0);

    return $this;
}

=method C<< $obj->populate() : I<self> >>

Contact the API to populate current object.

=cut

sub populate {
    my $this = shift;

    return $this if !$this->id || $this->populated || !$this->endpoint;

    my $request = Stancer::Core::Request->new();
    my $data = $request->get($this);

    $this->_set_populated(1);

    if ($data) {
        my $decoded = decode_json $data;

        $this->_api_data($decoded);
        $this->hydrate($decoded);

        for my $attr (@{$this->_inner_objects}) {
            if (defined $this->{$attr} && defined $decoded->{$attr}) {
                $this->{$attr}->_api_data($decoded->{$attr});
            }
        }
    }

    $this->_reset_modified();

    return $this;
}

=method C<< $obj->save() : I<self> >>

Save the current object.

=cut

sub save {
    my $this = shift;

    carp '"save" method is deprecated and will be removed in a later release, use the "send" method instead';

    return $this->send();
}

=method C<< $obj->send() : I<self> >>

Send the current object.

=cut

sub send { ## no critic (Subroutines::ProhibitBuiltinHomonyms)
    my $this = shift;

    return $this if $this->is_not_modified;

    my $request = Stancer::Core::Request->new();
    my $data;
    my $verb;

    if (defined $this->id) {
        $data = $request->patch($this);
        $verb = 'updated';
    } else {
        $data = $request->post($this);
        $verb = 'created';
    }

    $this->_set_populated(1);

    if ($data) {
        $this->hydrate(decode_json $data);
    }

    $this->_reset_modified();

    my @parts = split m/::/sm, ref $this;
    my $class = $parts[-1];

    $log->info(sprintf '%s %s %s', $class, $this->id, $verb);

    return $this;
}

=method C<< $obj->toJSON() : I<string> >>

Return a JSON representation of current object.

=cut

## no critic (Capitalization)
sub toJSON {
    my $this = shift;

    return JSON->new->convert_blessed->canonical->encode($this);
}
## use critic

=method C<< $obj->to_hash() : I<hash> >>

Return an hash representing the current object.

=cut

sub to_hash {
    my $this = shift;
    my $attrs = {};
    my @properties = keys %{$this->populate()};

    foreach my $attr (sort @properties) {
        next if any { $_ eq $attr } qw(endpoint populated refunds); # remove ignored attributes
        next if $attr =~ m/^_/sm; # remove private attributes

        if (blessed($this->$attr) && $this->$attr->isa(__PACKAGE__)) {
            $attrs->{$attr} = $this->$attr->to_hash;
        } else {
            $attrs->{$attr} = $this->$attr;
        }

        if (any { $_ eq $attr } @{$this->_boolean}) { # Parse boolean
            my $tmp = $this->$attr;

            $attrs->{$attr} = \1 if "$tmp" eq '1';
            $attrs->{$attr} = \0 if "$tmp" eq '0';
        }

        if (any { $_ eq $attr } @{$this->_integer}) { # Force integer
            $attrs->{$attr} *= 1;
        }
    }

    return $attrs;
}

=method C<< $obj->TO_JSON() : I<hash> >>

Return an hash representing the current object.

This method is used by L<JSON module|JSON/"OBJECT-SERIALISATION"> for convertions.

=cut

sub TO_JSON {
    my $this = shift;
    my $attrs = {};
    my @properties = keys %{$this};

    if ($this->id) {
        @properties = @{$this->_modified};

        return $this->id() if $this->is_not_modified;
    }

    foreach my $attr (sort @properties) {
        next if any { $_ eq $attr } @{$this->_json_ignore}; # remove ignored attributes
        next if $attr =~ m/^_/sm; # remove private attributes
        next if $attr eq 'id';
        next unless defined $this->$attr;

        $attrs->{$attr} = $this->$attr;

        if (any { $_ eq $attr } @{$this->_boolean}) { # Parse boolean
            my $tmp = $this->$attr;

            $attrs->{$attr} = \1 if "$tmp" eq '1';
            $attrs->{$attr} = \0 if "$tmp" eq '0';
        }

        if (any { $_ eq $attr } @{$this->_integer}) { # Force integer
            $attrs->{$attr} *= 1;
        }

        if (defined blessed($this->$attr) && blessed($this->$attr) eq 'DateTime') {
            if (any { $_ eq $attr } @{$this->_date_only}) { # Force date only
                $attrs->{$attr} = $this->$attr->ymd();
            } else {
                $attrs->{$attr} = $this->$attr->epoch();
            }
        }
    }

    return $attrs;
}

1;
