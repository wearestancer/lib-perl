package Stancer::Exceptions::Http::BadRequest;

use 5.020;
use strict;
use warnings;

# ABSTRACT: HTTP 400 - Bad request error
# VERSION

use Moo;

extends 'Stancer::Exceptions::Http::ClientSide';

use namespace::clean;

has '+log_level' => (
    default => 'critical',
);

1;
