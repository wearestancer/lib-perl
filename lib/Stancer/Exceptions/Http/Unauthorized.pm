package Stancer::Exceptions::Http::Unauthorized;

use 5.020;
use strict;
use warnings;

# ABSTRACT: HTTP 401 - Not authorized error
# VERSION

use Moo;

extends 'Stancer::Exceptions::Http::ClientSide';

use namespace::clean;

has '+log_level' => (
    default => 'critical',
);

1;
