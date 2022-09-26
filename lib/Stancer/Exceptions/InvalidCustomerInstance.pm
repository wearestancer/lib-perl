package Stancer::Exceptions::InvalidCustomerInstance;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid Customer instance
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid Customer instance.',
);

1;
