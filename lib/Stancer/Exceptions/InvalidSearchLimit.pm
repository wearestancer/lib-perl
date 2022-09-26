package Stancer::Exceptions::InvalidSearchLimit;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid search limit
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidSearchFilter';

use namespace::clean;

has '+message' => (
    default => 'Limit must be between 1 and 100.',
);

1;
