package Stancer::Refund;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Representation of a refund
# VERSION

use Stancer::Core::Types qw(coerce_datetime coerce_instance InstanceOf Maybe PaymentInstance Str);

use Stancer::Payment;
use Scalar::Util qw/blessed/;

use Moo;
use namespace::clean;

extends 'Stancer::Core::Object';
with 'Stancer::Role::Amount';

has '+endpoint' => (
    default => 'refunds',
);

use Stancer::Refund::Status;

=method C<< Stancer::Refund->new(I<$token>) : I<self> >>

This method accept an optional string, it will be used as an entity ID for API calls.

    # Create a refund
    my $payment = Stancer::Payment->new($token);

    $payment->refund();

    my $refunds = $payment->refunds;

    # Get an existing refund
    my $exist = Stancer::Refund->new($token);

=attr C<amount>

Read/Write integer, must be at least 50.

Refunded amount.

=attr C<currency>

Read/Write string, must be one of "EUR", "GBP" or "USD".

Refund currency.

=attr C<date_bank>

Read-only instance of C<DateTime>.

Value date.

=cut

has date_bank => (
    is => 'rwp',
    isa => Maybe[InstanceOf['DateTime']],
    builder => sub { $_[0]->_attribute_builder('date_bank') },
    coerce  => coerce_datetime(),
    lazy => 1,
    predicate => 1,
);

=attr C<date_refund>

Read-only instance of C<DateTime>.

Date when the refund is sent to the bank.

=cut

has date_refund => (
    is => 'rwp',
    isa => Maybe[InstanceOf['DateTime']],
    builder => sub { $_[0]->_attribute_builder('date_refund') },
    coerce  => coerce_datetime(),
    lazy => 1,
    predicate => 1,
);

=attr C<payment>

Read/Write instance of C<Stancer::Payment>.

Related payment object.

=cut

has payment => (
    is => 'rw',
    isa => Maybe[PaymentInstance],
    builder => sub { $_[0]->_attribute_builder('payment') },
    coerce  => coerce_instance('Stancer::Payment'),
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('payment') },
);

=attr C<status>

Read-only string.

Payment status.

=cut

has status => (
    is => 'rwp',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('status') },
    lazy => 1,
    predicate => 1,
);

1;
