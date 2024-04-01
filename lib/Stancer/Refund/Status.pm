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
};

=head1

=head2 failed

The refund has failed, refer to the response field for more details.

=head2 not_honored

When payment is disputed while trying to refund.

=head2 refund_sent

The refund has been sent to the bank, awaiting an answer.

=head2 refunded

The amount of the refund have been credited to your account.

=head2 to_refund

Refund will be processed within the day.

=cut

1;
