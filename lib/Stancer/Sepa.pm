package Stancer::Sepa;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Representation of a SEPA account
# VERSION

use Stancer::Core::Types qw(coerce_date coerce_datetime Bic Char Iban InstanceOf Maybe SepaCheckInstance Varchar);
use Try::Tiny;

use Moo;

extends 'Stancer::Core::Object';
with 'Stancer::Role::Country', 'Stancer::Role::Name';

use namespace::clean;

use Stancer::Sepa::Check;

has '+_date_only' => (
    default => sub{ [qw(date_birth)] },
);

has '+endpoint' => (
    default => 'sepa',
);

has '+_json_ignore' => (
    default => sub{ [qw(check endpoint created populated country last4)] },
);

=method C<< Stancer::Sepa->new() : I<self> >>

=method C<< Stancer::Sepa->new(I<$token>) : I<self> >>

=method C<< Stancer::Sepa->new(I<%args>) : I<self> >>

=method C<< Stancer::Sepa->new(I<\%args>) : I<self> >>

This method accept an optional string, it will be used as an entity ID for API calls.

    # Get an empty new sepa account
    my $new = Stancer::Sepa->new();

    # Get an existing sepa account
    my $exist = Stancer::Sepa->new($token);

=attr C<bic>

Read/Write string.

BIC code, also called SWIFT code.

=cut

has bic => (
    is => 'rw',
    isa => Maybe[Bic],
    builder => sub { $_[0]->_attribute_builder('bic') },
    coerce => sub {
        my $value = shift;

        return unless defined $value;

        $value =~ s/\s//gsm;

        return uc $value;
    },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('bic') },
);

=attr C<check>

Read-only instance of C<Stancer::SepaMail>.

Verification results.

=cut

has check => (
    is => 'rwp',
    isa => Maybe[SepaCheckInstance],
    builder => sub {
        my $self = shift;
        my $check;

        try {
            $check = Stancer::Sepa::Check->new($self->id)->populate() if defined $self->id;
        }
        catch {
            $_->throw() unless $_->isa('Stancer::Exceptions::Http::NotFound');
        };

        return $check;
    },
    lazy => 1,
    predicate => 1,
);

=attr C<country>

Read-only string.

Account country

=attr C<date_birth>

Read/Write instance of C<DateTime>.

A DateTime object representing the user birthdate.

This value is mandatory to use Sepa check service.

=cut

has date_birth => (
    is => 'rw',
    isa => Maybe[InstanceOf['DateTime']],
    builder => sub { $_[0]->_attribute_builder('date_birth') },
    coerce => coerce_date(),
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('date_birth') },
);

=attr C<date_mandate>

Read/Write instance of C<DateTime>.

A DateTime object representing the mandate signature date.

This value is mandatory if a C<mandate> is provided.

=cut

has date_mandate => (
    is => 'rw',
    isa => Maybe[InstanceOf['DateTime']],
    builder => sub { $_[0]->_attribute_builder('date_mandate') },
    coerce => coerce_datetime(),
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('date_mandate') },
);

=attr C<formatted_iban>

Read-only string.

Account number but formatted in 4 characters blocs separated with spaces.

=cut

sub formatted_iban {
    my $this = shift;
    my $iban = $this->iban;

    return if not defined $iban;

    $iban =~ s/(.{1,4})/$1 /gsm;
    $iban =~ s/\s*$//sm;

    return $iban;
}

=attr C<iban>

Read/Write string.

Account number

=cut

has iban => (
    is => 'rw',
    isa => Maybe[Iban],
    builder => sub { $_[0]->_attribute_builder('iban') },
    coerce => sub {
        my $value = shift;

        return unless defined $value;

        $value =~ s/\s//gsm;

        return uc $value;
    },
    lazy => 1,
    predicate => 1,
    trigger => sub {
        my $this = shift;

        $this->_add_modified('iban');
        $this->_set_last4(substr $this->iban, -4);
    },
);

=attr C<last4>

Read-only 4 characters string.

Last four account number

=cut

has last4 => (
    is => 'rwp',
    isa => Maybe[Char[4]],
    builder => sub { $_[0]->_attribute_builder('last4') },
    lazy => 1,
    predicate => 1,
);

=attr C<name>

Read/Write 4 to 64 characters.

Customer name

=attr C<mandate>

Read/Write 3 to 35 characters.

The mandate referring to the payment

=cut

has mandate => (
    is => 'rw',
    isa => Maybe[Varchar[3, 35]],
    builder => sub { $_[0]->_attribute_builder('mandate') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('mandate') },
);

=method C<validate>

Will ask for SEPA validation.

See L<sepa/check> for more information.

=cut

sub validate {
    my $self = shift;
    my $check = Stancer::Sepa::Check->new(sepa => $self);

    $self->_set_check($check->send());
    $self->_set_id($self->check->id);

    return $self;
}

1;
