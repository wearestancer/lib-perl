package Stancer::Exceptions::InvalidSearchStart;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid search start
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidSearchFilter';

use namespace::clean;

has '+message' => (
    default => 'Start must be a positive integer.',
);

1;
