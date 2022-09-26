package Stancer::Exceptions::MissingReturnUrl;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Missing return URL exception
# VERSION

use Moo;

extends 'Stancer::Exceptions::BadMethodCall';

use namespace::clean;

has '+message' => (
    default => 'You must provide a return URL.',
);

1;
