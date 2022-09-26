package Stancer::Exceptions::InvalidSepaInstance;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid Sepa instance
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid Sepa instance.',
);

1;
