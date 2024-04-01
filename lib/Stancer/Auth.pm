package Stancer::Auth;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Authentication configuration
# VERSION

use Stancer::Core::Types qw(Maybe Str Url);

use Moo;

extends 'Stancer::Core::Object';

use namespace::clean;

use Stancer::Auth::Status;

=method C<< Stancer::Auth->new() : I<self> >>

=method C<< Stancer::Auth->new(I<%args>) : I<self> >>

=method C<< Stancer::Auth->new(I<\%args>) : I<self> >>

This method accept an optional string, it will be used as an entity ID for API calls.

    # Get an empty new authentication configuration
    my $new = Stancer::Auth->new();

=attr C<redirect_url>

Read-only HTTPS url.

Location of the page which will start authentication process.

=cut

has redirect_url => (
    is => 'rwp',
    isa => Maybe[Url],
);

=attr C<return_url>

Read/write HTTPS url.

Location of the page which will receive authentication response.

=cut

has return_url => (
    is => 'rw',
    isa => Maybe[Url],
    trigger => sub { $_[0]->_add_modified('return_url') },
);

=attr C<status>

Read-only string.

Authentication status.

=cut

has status => (
    is => 'rwp',
    isa => Maybe[Str],
    default => Stancer::Auth::Status::REQUEST,
);

1;
