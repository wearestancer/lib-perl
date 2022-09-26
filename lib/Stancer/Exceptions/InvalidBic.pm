package Stancer::Exceptions::InvalidBic;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid BIC
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid BIC.',
);

1;
