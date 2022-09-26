package Stancer::Exceptions::MissingApiKey;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Missing API key exception
# VERSION

use Moo;

extends 'Stancer::Exceptions::BadMethodCall';

use namespace::clean;

has '+message' => (
    default => 'You did not provide valid API key.',
);

1;
