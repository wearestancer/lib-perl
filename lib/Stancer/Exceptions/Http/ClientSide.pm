package Stancer::Exceptions::Http::ClientSide;

use 5.020;
use strict;
use warnings;

# ABSTRACT: HTTP 4xx - Client side error
# VERSION

use Moo;

extends 'Stancer::Exceptions::Http';

use namespace::clean;

has '+_default_message' => (
    default => 'Client error',
);

has '+log_level' => (
    default => 'error',
);

1;
