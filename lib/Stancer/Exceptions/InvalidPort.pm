package Stancer::Exceptions::InvalidPort;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Exception thrown on miss-validation with a port.
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid port.',
);

1;
