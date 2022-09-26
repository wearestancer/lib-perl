package Stancer::Exceptions::MissingPaymentId;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Missing payment ID exception
# VERSION

use Moo;

extends 'Stancer::Exceptions::BadMethodCall';

use namespace::clean;

has '+message' => (
    default => 'A payment ID is mandatory. Maybe you forgot to send the payment.',
);

1;
