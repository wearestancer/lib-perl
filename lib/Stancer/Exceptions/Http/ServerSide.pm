package Stancer::Exceptions::Http::ServerSide;

use 5.020;
use strict;
use warnings;

# ABSTRACT: HTTP 5xx - Server side error
# VERSION

use Moo;

extends 'Stancer::Exceptions::Http';

use namespace::clean;

has '+_default_message' => (
    default => 'Server error',
);

has '+log_level' => (
    default => 'critical',
);

1;
