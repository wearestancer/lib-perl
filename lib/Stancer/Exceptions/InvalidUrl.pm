package Stancer::Exceptions::InvalidUrl;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid URL
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'critical',
);

has '+message' => (
    default => 'Invalid URL.',
);

1;
