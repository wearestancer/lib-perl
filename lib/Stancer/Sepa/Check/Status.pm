package Stancer::Sepa::Check::Status;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Sepa check status values
# VERSION

use Moo;
use namespace::clean;

use constant {
    AVAILABLE => 'available',
    CHECK_ERROR => 'check_error',
    CHECK_SENT => 'check_sent',
    CHECKED => 'checked',
    UNAVAILABLE => 'unavailable',
};

1;
