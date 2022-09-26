package Stancer::Exceptions::InvalidArgument;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid argument exception
# VERSION

use Moo;

extends 'Stancer::Exceptions::Throwable';

use namespace::clean;

has '+log_level' => (
    default => 'notice',
);

has '+message' => (
    default => 'Invalid argument.',
);

1;
