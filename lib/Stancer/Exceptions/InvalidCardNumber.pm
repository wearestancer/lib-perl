package Stancer::Exceptions::InvalidCardNumber;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid card number
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid card number.',
);

1;
