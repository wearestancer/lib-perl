package Stancer::Exceptions::InvalidSearchFilter;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid search filters
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid search filters.',
);

1;
