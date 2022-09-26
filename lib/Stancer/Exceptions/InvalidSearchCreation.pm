package Stancer::Exceptions::InvalidSearchCreation;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid search creation date
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidSearchFilter';

use namespace::clean;

has '+message' => (
    default => 'Created must be a position integer or a DateTime object and must be in the past.',
);

1;
