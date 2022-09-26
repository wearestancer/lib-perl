package Stancer::Exceptions::InvalidOrderId;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid order ID
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid order ID.',
);

1;
