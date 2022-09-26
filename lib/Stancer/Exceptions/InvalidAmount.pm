package Stancer::Exceptions::InvalidAmount;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid amount exception
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Amount must be greater than or equal to 50.',
);

1;
