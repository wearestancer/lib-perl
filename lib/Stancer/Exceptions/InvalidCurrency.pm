package Stancer::Exceptions::InvalidCurrency;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid currency exception
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'You must provide a valid currency.',
);

1;
