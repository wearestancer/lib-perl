package Stancer::Exceptions::BadMethodCall;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid method call exception
# VERSION

use Moo;

extends 'Stancer::Exceptions::Throwable';

use namespace::clean;

has '+log_level' => (
    default => 'critical',
);

has '+message' => (
    default => 'Bad method call.',
);

1;
