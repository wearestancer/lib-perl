package Stancer::Core::Iterator;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Abstract API object iterator
# VERSION

use Carp qw(croak);
use Stancer::Core::Request;
use Stancer::Exceptions::InvalidSearchCreation;
use Stancer::Exceptions::InvalidSearchFilter;
use Stancer::Exceptions::InvalidSearchLimit;
use Stancer::Exceptions::InvalidSearchStart;
use Stancer::Exceptions::InvalidSearchUntilCreation;
use JSON;
use Scalar::Util qw/blessed/;
use Try::Tiny;

use Moo;
use namespace::clean;

=head1 DESCRIPTION

You should not use this class directly.

This module is an internal class, regrouping method for every API object list.

=cut

sub _create_element {
    # Must be implemented in other iterator classes
}

sub _element_key {
    # Must be implemented in other iterator classes
}

=method C<< Stancer::Core::Iterator->new(I<$sub>) : I<self> >>

Create a new iterator.

A subroutine, C<$sub> is mandatory, it will be used on every iteration.

=cut

sub new {
    my ($class, $sub) = @_;
    my $self = {
        callback => $sub,
        stop => 0,
    };

    return bless $self, $class;
}

=method C<< $iterator->end() : I<self> >>

Stop the current iterator.

=cut

sub end {
    my $this = shift;

    $this->{stop} = 1;

    return $this;
}

=method C<< $iterator->next() : I<mixed> >>

Return the next element or C<undef> if no more element to iterate.

=cut

sub next { ## no critic (Subroutines::ProhibitBuiltinHomonyms)
    my $this = shift;

    if ($this->{stop}) {
        $this->{stop} = 0;

        return;
    }

    return $this->{callback}();
}

=method C<< Stancer::Core::Iterator->search(I<%terms>) : I<self> >>

=method C<< Stancer::Core::Iterator->search(I<\%terms>) : I<self> >>

Search element on the API with some terms.

I<%terms> (or I<\%terms>) are mandatory but accepted values will not be listed here, this method is internaly used
by L<Stancer::Payment/list> and L<Stancer::Dispute/list>.

=cut

sub search {
    my ($class, @args) = @_;
    my $obj = $class->_create_element(); # Mandatory for requests
    my $request = Stancer::Core::Request->new();
    my $more = 1;
    my @elements = ();
    my $data;

    if (scalar @args == 1) {
        $data = $args[0];
    } else {
        $data = {@args};
    }

    if (not keys %{$data}) {
        my $message = 'Invalid search filters.';

        Stancer::Exceptions::InvalidSearchFilter->throw(message => $message);
    }

    if (not defined $data->{start}) {
        $data->{start} = 0;
    }

    my $created_until = $data->{created_until};

    delete $data->{created_until};

    my $sub = sub {
        if (scalar @elements == 0 && $more) {
            my $response;

            try {
                $response = $request->get($obj, $data);
            }
            catch {
                return if blessed($_) && $_->isa('Stancer::Exceptions::Http::NotFound');

                $_->throw() if blessed($_) && $_->can('does') && $_->does('Throwable');

                croak $_;
            };

            if ($response) {
                my $json = decode_json $response;

                $more = $json->{range}->{has_more} == JSON::true;
                @elements = @{$json->{$class->_element_key}};

                $data->{start} += $json->{range}->{limit};
            }
        }

        my $value = shift @elements;

        if (defined $value) {
            my $item = $class->_create_element($value);

            return if defined $created_until && defined $item->created && $item->created->epoch > $created_until;
            return $item;
        }

        return;
    };

    return $class->new($sub);
}

sub _search_filter_created {
    my ($class, $data) = @_;
    my $created = $data->{created};
    my $blessed = blessed $data->{created};

    if (defined $blessed && $blessed eq 'DateTime') {
        $created = $data->{created}->epoch();
    }

    if (defined $blessed && $blessed eq 'DateTime::Span') {
        $created = $data->{created}->start->epoch();
        $data->{created_until} = $data->{created}->end->epoch();

        if ($data->{created}->start_is_open) {
            $created += 1;
        }

        if ($data->{created}->end_is_open) {
            $data->{created_until} -= 1;
        }
    }

    if ($created !~ m/^\d+$/sm) {
        my $message = 'Created must be a position integer or a DateTime object.';

        Stancer::Exceptions::InvalidSearchCreation->throw(message => $message);
    }

    if ($created > time) {
        my $message = 'Created must be in the past.';

        Stancer::Exceptions::InvalidSearchCreation->throw(message => $message);
    }

    return $created;
}

sub _search_filter_created_until {
    my ($class, $data) = @_;
    my $created_until = $data->{created_until};
    my $blessed = blessed $data->{created_until};

    if (defined $blessed && $blessed eq 'DateTime') {
        $created_until = $data->{created_until}->epoch();
    }

    if ($created_until !~ m/^\d+$/sm) {
        my $message = 'Created until must be a position integer or a DateTime object.';

        Stancer::Exceptions::InvalidSearchUntilCreation->throw(message => $message);
    }

    if ($created_until > time) {
        my $message = 'Created until must be in the past.';

        Stancer::Exceptions::InvalidSearchUntilCreation->throw(message => $message);
    }

    if (defined $data->{created}) {
        my $created = $class->_search_filter_created($data);

        if ($created_until < $created) {
            my $message = 'Created until can not be before created.';

            Stancer::Exceptions::InvalidSearchUntilCreation->throw(message => $message);
        }
    }

    return $created_until;
}

sub _search_filter_limit {
    my ($class, $data) = @_;

    if ($data->{limit} !~ m/^\d+$/sm) {
        my $message = 'Limit must be an integer.';

        Stancer::Exceptions::InvalidSearchLimit->throw(message => $message);
    }

    if ($data->{limit} < 1 || $data->{limit} > 100) {
        my $message = 'Limit must be between 1 and 100.';

        Stancer::Exceptions::InvalidSearchLimit->throw(message => $message);
    }

    return $data->{limit};
}

sub _search_filter_start {
    my ($class, $data) = @_;

    if ($data->{start} !~ m/^\d+$/sm) {
        my $message = 'Start must be a positive integer.';

        Stancer::Exceptions::InvalidSearchStart->throw(message => $message);
    }

    return $data->{start};
}

1;
