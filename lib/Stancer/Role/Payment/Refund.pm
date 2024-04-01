package Stancer::Role::Payment::Refund;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Payment refund relative role
# VERSION

use Stancer::Core::Types qw(ArrayRef RefundInstance);

use Stancer::Exceptions::InvalidAmount;
use Stancer::Exceptions::MissingPaymentId;
use Stancer::Refund::Status;
use Log::Any qw($log);
use Scalar::Util qw(blessed);

use Moo::Role;

requires qw(_attribute_builder amount currency id);

use namespace::clean;

=attr C<refundable_amount>

Read-only integer.

Paid amount available for a refund.

=cut

sub refundable_amount {
    my $this = shift;
    my $amount = $this->amount;

    for (@{$this->refunds}) {
        $amount -= $_->{amount};
    }

    return $amount;
}

=attr C<refunds>

Read-only array of C<Stancer::Refund> instance.

List of refund made on the payment.

=cut

has refunds => (
    is => 'rwp',
    isa => ArrayRef[RefundInstance],
    builder => sub { $_[0]->_attribute_builder('refunds') },
    coerce => sub {
        my $data = shift;
        my @refunds = ();

        if (defined $data) {
            for my $refund (@{$data}) {
                next if not defined $refund;

                if (blessed($refund) and blessed($refund) eq 'Stancer::Refund') {
                    push @refunds, $refund;
                } else {
                    push @refunds, Stancer::Refund->new($refund);
                }
            }
        }

        return \@refunds;
    },
    lazy => 1,
    predicate => 1,
);

=method C<< $payment->refund() : I<self> >>

=method C<< $payment->refund(I<$amount>) : I<self> >>

Refund a payment, or part of it.

I<$amount>, if provided, must be at least 50. If not present, all paid amount we be refund.

=cut

sub refund {
    my ($this, $amount) = @_;
    my $refund = Stancer::Refund->new(payment => $this);
    my $refunds = $this->refunds;

    Stancer::Exceptions::MissingPaymentId->throw() unless defined $this->id;

    if (defined $amount) {
        if ($amount > $this->refundable_amount) {
            my $refunded = $this->amount - $this->refundable_amount;
            my $pattern = 'You are trying to refund (%.02f %s) more than paid (%.02f %s).';
            my @params = (
                $amount / 100,
                uc $this->currency,
                $this->amount / 100,
                uc $this->currency,
            );

            if ($refunded != 0) {
                $pattern = 'You are trying to refund (%.02f %s) more than paid (%.02f %s with %.02f %s already refunded).';

                push @params, $refunded / 100;
                push @params, uc $this->currency;
            }

            my $message = sprintf $pattern, @params;

            Stancer::Exceptions::InvalidAmount->throw(message => $message);
        }

        $refund->amount($amount);
    }

    $refund->send();

    push @{$refunds}, $refund;
    $this->_set_refunds($refunds);

    my $message = sprintf 'Refund of %.02f %s on payment "%s"', (
        $refund->amount / 100,
        uc $refund->currency,
        $this->id,
    );

    $log->info($message);

    if ($refund->status ne Stancer::Refund::Status::TO_REFUND) {
        $this->_set_populated(0);
        $this->populate();

        for my $item (@{ $this->refunds }) {
            $item->payment($this);
        }
    }

    return $this;
}

1;
