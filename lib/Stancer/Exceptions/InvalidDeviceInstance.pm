package Stancer::Exceptions::InvalidDeviceInstance;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid Device instance
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidArgument';

use namespace::clean;

has '+log_level' => (
    default => 'debug',
);

has '+message' => (
    default => 'Invalid Device instance.',
);

1;
