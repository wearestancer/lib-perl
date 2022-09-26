package Stancer::Exceptions::InvalidExternalId;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid external ID
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid external ID.',
);

1;
