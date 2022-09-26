package Stancer::Exceptions::InvalidSearchOrderId;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid search order ID
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidSearchFilter';

use namespace::clean;

has '+message' => (
    default => 'Invalid order ID.',
);

1;
