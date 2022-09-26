package Stancer::Exceptions::InvalidEmail;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid email address
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid email address.',
);

1;
