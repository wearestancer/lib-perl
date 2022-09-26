package Stancer::Exceptions::InvalidDescription;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid description
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid description.',
);

1;
