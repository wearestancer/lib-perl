package Stancer::Refund::Status;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Refund status values
# VERSION

use Moo;
use namespace::clean;

use constant {
    NOT_HONORED => 'not_honored',
    PAYMENT_CANCELED => 'payment_canceled',
    REFUND_SENT => 'refund_sent',
    REFUNDED => 'refunded',
    TO_REFUND => 'to_refund',

    # Alias
    SENT => 'refund_sent',
};

1;
