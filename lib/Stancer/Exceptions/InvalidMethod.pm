package Stancer::Exceptions::InvalidMethod;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid method
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid method.',
);

1;
