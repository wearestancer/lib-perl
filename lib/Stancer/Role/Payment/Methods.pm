package Stancer::Role::Payment::Methods;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Payment's methods relative role
# VERSION

use Stancer::Core::Types qw(coerce_instance ArrayRef CardInstance Enum Maybe SepaInstance Str);
use List::MoreUtils qw(any);

use Moo::Role;

requires qw(_add_modified _attribute_builder _set_method);

use namespace::clean;

=attr C<card>

Read/Write instance of C<Stancer::Card>.

Target card for the payment.

=cut

has card => (
    is => 'rw',
    isa => Maybe[CardInstance],
    builder => sub { $_[0]->_attribute_builder('card') },
    coerce => coerce_instance('Stancer::Card'),
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('card')->_set_method('card') },
);

=attr C<method>

Read-only string, should be "card" or "sepa".

Payment method used.

=cut

has method => (
    is => 'rwp',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('method') },
    lazy => 1,
    predicate => 1,
);

=attr C<methods_allowed>

Read/Write arrayref of string.

List of methods allowed to be used on payment page.

You can pass a C<string> or an C<arrayref> of C<string>, we will always return an C<arrayref> of C<string>.

=cut

has methods_allowed => (
    is => 'rw',
    isa => Maybe[ArrayRef[Enum['card', 'sepa']]],
    builder => sub { $_[0]->_attribute_builder('methods_allowed') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('methods_allowed') },
);

around methods_allowed => sub {
    my ($orig, $class, $args) = @_;

    return $class->$orig unless defined $args;

    $args = [$args] if ref $args eq q//;

    if (
            (not $class->_process_hydratation)
        && defined $class->currency
        && $class->currency ne 'eur'
        && any { (defined $_) && ($_ eq 'sepa') } @{$args}
    ) {
        my $message = sprintf 'You can not ask for "%s" with "%s" currency.', (
            'sepa',
            uc $class->currency,
        );

        Stancer::Exceptions::InvalidMethod->throw(message => $message);
    }

    return $class->$orig($args);
};

=attr C<sepa>

Read/Write instance of C<Stancer::Sepa>.

Target sepa account for the payment.

=cut

has sepa => (
    is => 'rw',
    isa => Maybe[SepaInstance],
    builder => sub { $_[0]->_attribute_builder('sepa') },
    coerce => coerce_instance('Stancer::Sepa'),
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('sepa')->_set_method('sepa') },
);

1;
