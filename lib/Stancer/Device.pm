package Stancer::Device;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Device representation
# VERSION

use Stancer::Core::Types qw(:network Maybe Str);

use Moo;
use namespace::clean;

extends 'Stancer::Core::Object';

has '+_integer' => (
    default => sub{ [qw(port)] },
);

=method C<< Stancer::Device->new() : I<self> >>

=method C<< Stancer::Device->new(I<%args>) : I<self> >>

=method C<< Stancer::Device->new(I<\%args>) : I<self> >>

You may not need to create yourself a device instance, it will automatically be created for you.

    # Get an empty new device
    my $new = Stancer::Device->new();

This object needs a valid IP address (IPv4 or IPv6) ans a valid port, it will automatically used environment
variables as created by Apache or nginx (aka C<SERVER_ADDR> and C<SERVER_PORT>).

If variables are not available or if you are using a proxy, you must give IP and port at object instanciation.

    my $device = Stancer::Device->new(ip => $ip, port => $port);

=attr C<city>

Read/Write string.

Customer's city.

=cut

has city => (
    is => 'rw',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('country') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('city') },
);

=attr C<country>

Read/Write string.

Customer's country.

=cut

has country => (
    is => 'rw',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('country') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('country') },
);

=attr C<http_accept>

Read/Write string.

Customer's browser acceptance.

=cut

has http_accept => (
    is => 'rw',
    isa => Maybe[Str],
    trigger => sub { $_[0]->_add_modified('http_accept') },
);

=attr C<ip>

Read/write IP address.

Customer's IP address.

May be an IPv4 (aka 212.27.48.10) or an IPv6 (2a01:e0c:1::1).

=cut

has ip => (
    is => 'rw',
    isa => Maybe[IpAddress],
    trigger => sub { $_[0]->_add_modified('ip') },
);

=attr C<languages>

Read/Write string.

Customer's browser accepted languages.

=cut

has languages => (
    is => 'rw',
    isa => Maybe[Str],
    trigger => sub { $_[0]->_add_modified('languages') },
);

=attr C<port>

Read/Write integer.

Customer's port.

=cut

has port => (
    is => 'rw',
    isa => Maybe[Port],
    trigger => sub { $_[0]->_add_modified('port') },
);

=attr C<user_agent>

Read/Write string.

Customer's browser user agent.

=cut

has user_agent => (
    is => 'rw',
    isa => Maybe[Str],
    trigger => sub { $_[0]->_add_modified('user_agent') },
);

=method C<< Stancer::Device->hydrate_from_env() : I<self> >>

Hydrate frpm environment.

=cut

sub hydrate_from_env {
    my $this = shift;

    $this->http_accept($ENV{HTTP_ACCEPT}) if defined $ENV{HTTP_ACCEPT} and not defined $this->http_accept;
    $this->ip($ENV{SERVER_ADDR}) if defined $ENV{SERVER_ADDR} and not defined $this->ip;
    $this->languages($ENV{HTTP_ACCEPT_LANGUAGE}) if defined $ENV{HTTP_ACCEPT_LANGUAGE} and not defined $this->languages;
    $this->port($ENV{SERVER_PORT}) if defined $ENV{SERVER_PORT} and not defined $this->port;
    $this->user_agent($ENV{HTTP_USER_AGENT}) if defined $ENV{HTTP_USER_AGENT} and not defined $this->user_agent;

    Stancer::Exceptions::InvalidIpAddress->throw() if not defined $this->ip;
    Stancer::Exceptions::InvalidPort->throw() if not defined $this->port;

    return $this;
}

1;
