package Stancer::Role::Country;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Country role
# VERSION

use Stancer::Core::Types qw(Maybe Str Varchar);

use Moo::Role;

requires qw(_add_modified _attribute_builder);

use namespace::clean;

=attr C<city>

Read/Write string.

Customer's city.

=cut

has city => (
    is => 'rwp',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('country') },
    lazy => 1,
    predicate => 1,
);

=attr C<country>

Read-only string.

Element country.

=cut

has country => (
    is => 'rwp',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('country') },
    lazy => 1,
    predicate => 1,
);

=attr C<zip_code>

Read-only string.

Element zip_code.

=cut

has zip_code => (
    is => 'rw',
    isa => Maybe[Varchar[2, 8]],
    builder => sub { $_[0]->_attribute_builder('zip_code') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('zip_code') },
);

1;
