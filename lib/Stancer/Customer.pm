package Stancer::Customer;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Customer representation
# VERSION

use Stancer::Core::Types qw(Email ExternalId Maybe Mobile);

use Stancer::Exceptions::BadMethodCall;

use Moo;

extends 'Stancer::Core::Object';
with 'Stancer::Role::Name';

use namespace::clean;

has '+endpoint' => (
    default => 'customers',
);

=method C<< Stancer::Customer->new() : I<self> >>

=method C<< Stancer::Customer->new(I<$token>) : I<self> >>

=method C<< Stancer::Customer->new(I<%args>) : I<self> >>

=method C<< Stancer::Customer->new(I<\%args>) : I<self> >>

This method accept an optional string, it will be used as an entity ID for API calls.

    # Get an empty new customer
    my $new = Stancer::Customer->new();

    # Get an existing customer
    my $exist = Stancer::Customer->new($token);

=attr C<email>

Read/Write 5 to 64 characters.

Customer email

=cut

has email => (
    is => 'rw',
    isa => Maybe[Email],
    builder => sub { $_[0]->_attribute_builder('email') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('email') },
);

=attr C<external_id>

Read/Write 36 characters maximum string.

External for the API, you can store your customer's identifier here.

=cut

has external_id => (
    is => 'rw',
    isa => Maybe[ExternalId],
    builder => sub { $_[0]->_attribute_builder('external_id') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('external_id') },
);

=attr C<mobile>

Read/Write 8 to 16 characters.

Customer mobile phone number

=cut

has mobile => (
    is => 'rw',
    isa => Maybe[Mobile],
    builder => sub { $_[0]->_attribute_builder('mobile') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('mobile') },
);

=attr C<name>

Read/Write 4 to 64 characters.

Customer name

=cut

around send => sub {
    my ($orig, $this, $values) = @_;

    if (!$this->has_id && !$this->has_email && !$this->has_mobile) {
        my $message = 'You must provide an email or a phone number to create a customer.';

        Stancer::Exceptions::BadMethodCall->throw(message => $message);
    }

    return $this->$orig($values);
};

1;
