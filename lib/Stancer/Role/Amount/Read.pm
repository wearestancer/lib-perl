package Stancer::Role::Amount::Read;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Amount read-only role
# VERSION

use Stancer::Core::Types qw(Amount Maybe Currency);

use Moo::Role;

requires qw(_add_modified _attribute_builder);

use namespace::clean;

=attr C<amount>

Read-only integer.

Amount.

=cut

has amount => (
    is => 'rwp',
    isa => Maybe[Amount],
    builder => sub { $_[0]->_attribute_builder('amount') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('amount') },
);

=attr C<currency>

Read-only string.

Currency.

=cut

has currency => (
    is => 'rwp',
    isa => Maybe[Currency],
    builder => sub { $_[0]->_attribute_builder('currency') },
    coerce => sub { defined $_[0] ? lc $_[0] : $_[0] },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('currency') },
);

1;
