package Stancer::Exceptions::InvalidCardVerificationCode;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid CVC
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid CVC.',
);

1;
