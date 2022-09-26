package Stancer::Exceptions::InvalidSearchUntilCreation;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid search until creation date
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidSearchFilter';

use namespace::clean;

has '+message' => (
    default => 'Created until must be a position integer or a DateTime object and must be in the past.',
);

1;
