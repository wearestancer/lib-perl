package Stancer::Payment::Status;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Payment status values
# VERSION

use Moo;
use namespace::clean;

use constant {
    AUTHORIZE => 'authorize',
    AUTHORIZED => 'authorized',
    CANCELED => 'canceled',
    CAPTURE => 'capture',
    CAPTURE_SENT => 'capture_sent',
    CAPTURED => 'captured',
    DISPUTED => 'disputed',
    EXPIRED => 'expired',
    FAILED => 'failed',
    TO_CAPTURE => 'to_capture',
};

1;
