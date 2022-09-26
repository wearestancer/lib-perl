package Stancer::Exceptions::InvalidPaymentInstance;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid Payment instance
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid Payment instance.',
);

1;
