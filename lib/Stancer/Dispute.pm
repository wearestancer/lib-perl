package Stancer::Dispute;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Dispute representation
# VERSION

use Stancer::Core::Types qw(coerce_instance Maybe OrderId PaymentInstance Varchar);

use Stancer::Core::Iterator::Dispute;
use Stancer::Payment;
use Scalar::Util qw/blessed/;

use Moo;
use namespace::clean;

extends 'Stancer::Core::Object';

=method C<< Stancer::Dispute->new() : I<self> >>

=method C<< Stancer::Dispute->new(I<$token>) : I<self> >>

=method C<< Stancer::Dispute->new(I<%args>) : I<self> >>

=method C<< Stancer::Dispute->new(I<\%args>) : I<self> >>

This method accept an optional string, it will be used as an entity ID for API calls.

    # Get an empty new payment
    my $new = Stancer::Dispute->new();

    # Get an existing payment
    my $exist = Stancer::Dispute->new($token);

=cut

has '+endpoint' => (
    default => 'disputes',
);

=attr C<order_id>

Read/Write string, 1 to 24 characters.

External order id.

=cut

has order_id => (
    is => 'rw',
    isa => Maybe[OrderId],
    builder => sub { $_[0]->_attribute_builder('order_id') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('order_id') },
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

=method C<< Dispute->list(I<%terms>) : I<DisputeIterator> >>

=method C<< Dispute->list(I<\%terms>) : I<DisputeIterator> >>

List all disputes.

C<%terms> must be an hash or a reference to an hash (C<\%terms>) with at least one of the following key :

=over

=item C<created>

Must be an unix timestamp, a C<DateTime> or a C<DateTime::Span> object which will filter payments
created after this value.
If a C<DateTime::Span> is passed, C<created_until> will be ignored and replaced with C<< DateTime::Span->end >>.

=item C<created_until>

Must be an unix timestamp or a C<DateTime> object which will filter payments created before this value.
If a C<DateTime::Span> is passed to C<created>, this value will be ignored.

=item C<limit>

Must be an integer between 1 and 100 and will limit the number of objects to be returned.
API defaults is to return 10 elements.

=item C<start>

Must be an integer and will be used as a pagination cursor, starts at 0.

=back

=cut

sub list {
    my ($class, @args) = @_;

    return Stancer::Core::Iterator::Dispute->search(@args);
}

1;
