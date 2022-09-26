package Stancer::Exceptions::InvalidCardExpiration;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Exception thrown on miss-validation with card expiration.
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Expiration is invalid.',
);

1;
