package Stancer::Exceptions::InvalidName;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid name
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid name.',
);

1;
