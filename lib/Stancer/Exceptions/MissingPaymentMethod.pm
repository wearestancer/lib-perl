package Stancer::Exceptions::MissingPaymentMethod;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Missing payment method exception
# VERSION

use Moo;

extends 'Stancer::Exceptions::BadMethodCall';

use namespace::clean;

has '+message' => (
    default => 'You must provide a valid credit card or SEPA account to make a payment.',
);

1;
