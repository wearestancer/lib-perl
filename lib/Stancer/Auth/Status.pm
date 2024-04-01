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

=head1 Constants

=head2 attempted

Customer was redirected to his bank for authentication.

=head2 available

Customer strong authentication is possible.

=head2 declined

Authentication declined.

=head2 expired

Authentication sessions expired after 6 hours.

=head2 failed

Authentication failed.

=head2 requested

A strong authentication is awaiting for more information.

=head2 success

Authentication succeeded, processing can continue.

=head2 unavailable

The strong authentication is not available for this payment method.

=cut

1;
