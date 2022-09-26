package Stancer::Exceptions::InvalidExpirationYear;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Exception thrown on miss-validation with expiration year.
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidCardExpiration';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Expiration year is invalid.',
);

1;
