package Stancer::Role::Name;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Name role
# VERSION

use Stancer::Core::Types qw(Maybe Name);

use Moo::Role;

requires qw(_add_modified _attribute_builder);

use namespace::clean;

=attr C<name>

Read/Write 4 to 64 characters string.

Element's name

=cut

has name => (
    is => 'rw',
    isa => Maybe[Name],
    builder => sub { $_[0]->_attribute_builder('name') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('name') },
);

1;
