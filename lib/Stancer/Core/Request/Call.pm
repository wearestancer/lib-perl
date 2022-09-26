package Stancer::Core::Request::Call;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Register API call
# VERSION

use Stancer::Core::Types qw(InstanceOf Maybe);

use Moo;
use namespace::clean;

=head1 SYNOPSIS

This class serves as a call register.

You do not need to instanciate it directly, you should only see them in debug mode.

=attr C<exception>

Read-only instance of C<Stancer::Exceptions::Throwable>.

If the request result to an exception, you can see it here.

=cut

has exception => (
    is => 'ro',
    isa => Maybe[InstanceOf['Stancer::Exceptions::Throwable']],
);

=attr C<request>

Read-only instance of C<HTTP::Request>.

The request.

=cut

has request => (
    is => 'ro',
    isa => InstanceOf['HTTP::Request'],
);

=attr C<response>

Read-only instance of C<HTTP::Response>.

The response to a request.

=cut

has response => (
    is => 'ro',
    isa => InstanceOf['HTTP::Response'],
);

1;
