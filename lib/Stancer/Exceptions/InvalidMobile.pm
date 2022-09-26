package Stancer::Exceptions::InvalidMobile;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid mobile phone number
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid mobile phone number.',
);

1;
