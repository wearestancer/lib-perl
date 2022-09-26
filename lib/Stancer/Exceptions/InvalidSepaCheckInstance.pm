package Stancer::Exceptions::InvalidSepaCheckInstance;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid Sepa check instance
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid Sepa check instance.',
);

1;
