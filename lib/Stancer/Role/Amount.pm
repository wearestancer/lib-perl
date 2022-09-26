package Stancer::Role::Amount;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Amount role
# VERSION

use Stancer::Core::Types qw(Amount Maybe Currency);

use Moo::Role;
use namespace::clean;

requires qw(_add_modified _attribute_builder);

=attr C<amount>

Read/Write integer, must be at least 50.

Amount to pay.

=cut

has amount => (
    is => 'rw',
    isa => Maybe[Amount],
    builder => sub { $_[0]->_attribute_builder('amount') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('amount') },
);

=attr C<currency>

Read/Write string, must be one of "EUR", "GBP" or "USD".

Payment currency.

=cut

has currency => (
    is => 'rw',
    isa => Maybe[Currency],
    builder => sub { $_[0]->_attribute_builder('currency') },
    coerce => sub { defined $_[0] ? lc $_[0] : $_[0] },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('currency') },
);

1;
