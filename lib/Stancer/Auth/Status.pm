package Stancer::Auth::Status;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Auth status values
# VERSION

use Moo;
use namespace::clean;

use constant {
    ATTEMPTED => 'attempted',
    AVAILABLE => 'available',
    DECLINED => 'declined',
    EXPIRED => 'expired',
    FAILED => 'failed',
    REQUEST => 'request',
    REQUESTED => 'requested',
    SUCCESS => 'success',
    UNAVAILABLE => 'unavailable',
};

1;
