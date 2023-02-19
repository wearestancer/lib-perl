package Stancer::Sepa::Check;

use 5.020;
use strict;
use warnings;

# ABSTRACT: This will SEPAmail, a french service allowing to verify bank details on SEPA.
# VERSION

use Stancer::Core::Types qw(coerce_boolean Bool Maybe Num SepaInstance Str Varchar);
use Stancer::Sepa;

use Moo;

extends 'Stancer::Core::Object';

use namespace::clean;

use Stancer::Sepa::Check::Status;

has '+_boolean' => (
    default => sub{ [qw(date_birth)] },
);

has '+endpoint' => (
    default => 'sepa/check',
);

=attr C<date_birth>

Read-only boolean.

Is the provided birth date verified ?

=cut

has date_birth => (
    is => 'rwp',
    isa => Maybe[Bool],
    builder => sub { $_[0]->_attribute_builder('date_birth') },
    coerce => coerce_boolean(),
    lazy => 1,
    predicate => 1,
);

=attr C<response>

Read-only 2 or 4 characters string.

API response code.

=cut

has response => (
    is => 'rwp',
    isa => Maybe[Varchar[2, 4]],
    builder => sub { $_[0]->_attribute_builder('response') },
    lazy => 1,
    predicate => 1,
);

=attr C<sepa>

Read-only instance of C<Stancer::Sepa>.

Verified SEPA.

=cut

has sepa => (
    is => 'rwp',
    isa => Maybe[SepaInstance],
    builder => sub {
        my $self = shift;

        return unless $self->id;
        return Stancer::Sepa->new($self->id);
    },
    lazy => 1,
    predicate => 1,
);

=attr C<score_name>

Read-only float.

Distance between provided name and account name.

Distance is a percentage, you will have a float between 0 and 1.

=cut

has score_name => (
    is => 'rwp',
    isa => Maybe[Num],
    builder => sub { $_[0]->_attribute_builder('score_name') },
    coerce => sub {
        my $value = shift;

        return unless defined $value;
        return $value / 100;
    },
    lazy => 1,
    predicate => 1,
);

=attr C<status>

Read-only string, should be a C<Stancer::Sepa::Check::Status> constants.

Verification status.

=cut

has status => (
    is => 'rwp',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('status') },
    lazy => 1,
    predicate => 1,
);

sub TO_JSON {
    my $self = shift;

    return {} unless defined $self->sepa;
    return { id => $self->sepa->id } if defined $self->sepa->id;
    return $self->sepa->TO_JSON();
}

1;
