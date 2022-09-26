package Stancer::Exceptions::Http;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Abstract exception for every HTTP errors
# VERSION

use Stancer::Core::Types qw(InstanceOf);
use HTTP::Status qw(status_message);

use Moo;

extends 'Stancer::Exceptions::Throwable';

use namespace::clean;

has '+log_level' => (
    default => 'warning',
);

has '+message' => (
    default => sub {
        my $this = shift;
        my $code = $this->status;

        return status_message($code) if defined $code;
        return $this->_default_message;
    },
    lazy => 1,
);

has '_default_message' => (
    is => 'ro',
    default => 'HTTP error',
);

=attr C<request>

Read-only HTTP::Request instance.

The request that resulted that error.

=cut

has request => (
    is => 'ro',
    isa => InstanceOf['HTTP::Request'],
);

=attr C<response>

Read-only HTTP::Response instance.

The response that resulted that error.

=cut

has response => (
    is => 'ro',
    isa => InstanceOf['HTTP::Response'],
);


=attr C<status>

Read-only integer.

HTTP status code

=cut

has status => (
    is => 'ro',
    builder => sub {
        my $this = shift;
        my @parts = split m/::/sm, ref $this;
        my $class = $parts[-1];

        $class =~ s/([[:upper:]])/_$1/xgsm;

        my $constant = 'HTTP' . uc $class;

        return HTTP::Status->$constant if HTTP::Status->can($constant);
    },
);

=method C<< Stancer::Exceptions::Http->factory( I<$status> ) >>

=method C<< Stancer::Exceptions::Http->factory( I<$status>, I<%args> ) >>

=method C<< Stancer::Exceptions::Http->factory( I<$status>, I<\%args> ) >>

Return an instance of HTTP exception depending on C<$status>.

=cut

sub factory {
    my ($class, $status, @args) = @_;
    my $data;

    if (scalar @args == 1) {
        $data = $args[0];
    } else {
        $data = {@args};
    }

    $data->{status} = $status;

    my $instance = Stancer::Exceptions::Http->new($data);

    require Stancer::Exceptions::Http::BadRequest;
    require Stancer::Exceptions::Http::ClientSide;
    require Stancer::Exceptions::Http::Conflict;
    require Stancer::Exceptions::Http::InternalServerError;
    require Stancer::Exceptions::Http::NotFound;
    require Stancer::Exceptions::Http::ServerSide;
    require Stancer::Exceptions::Http::Unauthorized;

    $instance = Stancer::Exceptions::Http::ClientSide->new($data) if $status >= 400;
    $instance = Stancer::Exceptions::Http::ServerSide->new($data) if $status >= 500;

    $instance = Stancer::Exceptions::Http::BadRequest->new($data) if $status == 400;
    $instance = Stancer::Exceptions::Http::Unauthorized->new($data) if $status == 401;
    $instance = Stancer::Exceptions::Http::NotFound->new($data) if $status == 404;
    $instance = Stancer::Exceptions::Http::Conflict->new($data) if $status == 409;
    $instance = Stancer::Exceptions::Http::InternalServerError->new($data) if $status == 500;

    return $instance;
}

1;
