package Stancer::Exceptions::InvalidUniqueId;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid unique ID
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid unique ID.',
);

1;
