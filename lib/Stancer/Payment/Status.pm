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

=head1 Constants

=head2 authorize

Ask the authorization.

=head2 authorized

The bank authorized the payment but the transaction will only be processed when the capture will be set to C<true>.

=head2 canceled

The payment will not be performed, no money will be captured.

=head2 capture

Ask to authorize and capture the payment.

=head2 capture_sent

The capture operation is being processed, the payment can not be cancelled anymore,
refunds must wait the end of the capture process.

=head2 captured

The amount of the payment have been credited to your account.

=head2 disputed

The customer declined the payment after it have been captured on your account.

=head2 expired

The authorisation was not captured and expired after 7 days.

=head2 failed

The payment has failed, refer to the response field for more details.

=head2 refused

The payment has been refused.

=head2 to_capture

The bank authorized the payment, money will be processed within the day.

=cut

1;
