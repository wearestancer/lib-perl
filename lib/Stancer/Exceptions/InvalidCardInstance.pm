package Stancer::Exceptions::InvalidCardInstance;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid Card instance
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid Card instance.',
);

1;
