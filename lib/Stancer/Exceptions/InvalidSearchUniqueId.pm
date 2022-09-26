package Stancer::Exceptions::InvalidSearchUniqueId;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Invalid search unique ID
# VERSION

use Moo;

extends 'Stancer::Exceptions::InvalidSearchFilter';

use namespace::clean;

has '+message' => (
    default => 'Invalid unique ID.',
);

1;
