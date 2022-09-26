package Stancer::Exceptions::InvalidIban;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid IBAN
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid IBAN.',
);

1;
