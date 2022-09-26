package Stancer::Payment;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Stancer Perl library
# VERSION

use Stancer::Core::Types qw(:all Char InstanceOf Maybe Str);

use Stancer::Core::Iterator::Payment;
use Stancer::Exceptions::BadMethodCall;
use Stancer::Exceptions::InvalidAmount;
use Stancer::Exceptions::InvalidCardExpiration;
use Stancer::Exceptions::InvalidCurrency;
use Stancer::Exceptions::InvalidMethod;
use Stancer::Exceptions::MissingPaymentMethod;

use DateTime;
use List::MoreUtils qw(any);
use Log::Any qw($log);
use Scalar::Util qw/blessed/;

use Moo;

extends 'Stancer::Core::Object';
with qw(
    Stancer::Role::Amount
    Stancer::Role::Country
    Stancer::Role::Payment::Auth
    Stancer::Role::Payment::Methods
    Stancer::Role::Payment::Page
    Stancer::Role::Payment::Refund
);

use namespace::clean;

use Stancer::Auth;
use Stancer::Card;
use Stancer::Config;
use Stancer::Customer;
use Stancer::Device;
use Stancer::Dispute;
use Stancer::Payment::Status;
use Stancer::Refund;
use Stancer::Sepa;

has '+_boolean' => (
    default => sub{ [qw(auth capture)] },
);

has '+_inner_objects' => (
    default => sub{ [qw(card customer sepa)] },
);

has '+_json_ignore' => (
    default => sub{ [qw(endpoint created populated method refunds)] },
);

has '+endpoint' => (
    default => 'checkout',
);

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Stancer::Payment;

    my $payment = Stancer::Payment->new();
    ...

=method C<< Stancer::Payment->new() : I<self> >>

=method C<< Stancer::Payment->new(I<$token>) : I<self> >>

=method C<< Stancer::Payment->new(I<%args>) : I<self> >>

=method C<< Stancer::Payment->new(I<\%args>) : I<self> >>

This method accept an optional string, it will be used as an entity ID for API calls.

    # Get an empty new payment
    my $new = Stancer::Payment->new();

    # Get an existing payment
    my $exist = Stancer::Payment->new($token);

=attr C<amount>

Read/Write integer, must be at least 50.

Amount to pay.

=attr C<auth>

Read/Write instance of C<Stancer::Auth>.

May accept a boolean if you use our payment page or a HTTPS url as an alias for `Stancer::Auth::return_url`.

=attr C<capture>

Read/Write boolean.

Do we need to capture the payment ?

=cut

has capture => (
    is => 'rw',
    isa => Maybe[Bool],
    builder => sub { $_[0]->_attribute_builder('capture') },
    coerce  => coerce_boolean(),
    lazy => 1,
    predicate => 1,
);

=attr C<card>

Read/Write instance of C<Stancer::Card>.

Target card for the payment.

=attr C<country>

Read-only string.

Card country.

=attr C<currency>

Read/Write string, must be one of "EUR", "GBP" or "USD".

Payment currency.

=cut

around currency => sub {
    my ($orig, $class, $args) = @_;

    return $class->$orig unless defined $args;

    my $methods = $class->methods_allowed;

    if (
            (not $class->_process_hydratation)
        && lc $args eq 'eur'
        && defined $methods
        && any { $_ eq 'sepa' } @{$methods}
    ) {
        my $message = sprintf 'You can not ask for "%s" with "%s" method.', (
            uc $args,
            'sepa',
        );

        Stancer::Exceptions::InvalidCurrency->throw(message => $message);
    }

    return $class->$orig($args);
};

=attr C<customer>

Read/Write instance of C<Stancer::Customer>.

Customer handling the payment.

=cut

has customer => (
    is => 'rw',
    isa => Maybe[CustomerInstance],
    builder => sub { $_[0]->_attribute_builder('customer') },
    coerce  => coerce_instance('Stancer::Customer'),
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('customer') },
);

=attr C<date_bank>

Read-only instance of C<DateTime>.

Value date.

=cut

has date_bank => (
    is => 'rwp',
    isa => Maybe[InstanceOf['DateTime']],
    builder => sub { $_[0]->_attribute_builder('date_bank') },
    coerce  => coerce_datetime(),
    lazy => 1,
    predicate => 1,
);

=attr C<description>

Read/Write string, 3 to 64 characters.

Description

=cut

has description => (
    is => 'rw',
    isa => Maybe[Description],
    builder => sub { $_[0]->_attribute_builder('description') },
    predicate => 1,
    lazy => 1,
    trigger => sub { $_[0]->_add_modified('description') },
);

=attr C<device>

Read/Write instance of C<Stancer::Device>.

Information about device fulfuling the payment.

C<Stancer::Device> needs IP address and port to work, it will automatically used environment
variables as created by Apache or nginx (aka C<SERVER_ADDR> and C<SERVER_PORT>).

If variables are not available or if you are using a proxy, you must give IP and port at object instanciation.

    $payment->device(ip => $ip, port => $port);

=attr C<method>

Read-only string, should be "card" or "sepa".

Payment method used.

=attr C<methods_allowed>

Read/Write arrayref of string.

List of methods allowed to be used on payment page.

You can pass a C<string> or an C<arrayref> of C<string>, we will always return an C<arrayref> of C<string>.

=attr C<order_id>

Read/Write string, 1 to 36 characters.

External order id.

=cut

has order_id => (
    is => 'rw',
    isa => Maybe[OrderId],
    builder => sub { $_[0]->_attribute_builder('order_id') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('order_id') },
);

=attr C<refundable_amount>

Read-only integer.

Paid amount available for a refund.

=attr C<refunds>

Read-only array of C<Stancer::Refund> instance.

List of refund made on the payment.

=attr C<response>

Read-only 2 or 4 characters string.

API response code.

=cut

has response => (
    is => 'rwp',
    isa => Maybe[Varchar[2, 4]],
    builder => sub { $_[0]->_attribute_builder('response') },
    lazy => 1,
    predicate => 1,
);

=attr C<response_author>

Read-only string.

API response author.

=cut

has response_author => (
    is => 'rwp',
    isa => Maybe[Char[6]],
    builder => sub { $_[0]->_attribute_builder('response_author') },
    lazy => 1,
    predicate => 1,
);

=attr C<return_url>

Read/Write string.

URL used to return to your store when using the payment page.

=attr C<sepa>

Read/Write instance of C<Stancer::Sepa>.

Target sepa account for the payment.

=attr C<status>

Read/Write string.

Payment status.

=cut

has status => (
    is => 'rw',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('status') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('status') },
);

=attr C<unique_id>

Read/Write string, 1 to 36 characters.

External unique id.

If a C<unique_id> is provided, it will used to deduplicate payment.

This should be used only with an identifier unique in your system.
You should use an auto-increment or a UUID made in your environment.

=cut

has unique_id => (
    is => 'rw',
    isa => Maybe[UniqueId],
    builder => sub { $_[0]->_attribute_builder('unique_id') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('unique_id') },
);

=method C<< $payment->del() : I<void> >>

This method is not allowed in this context and will always throw an error.

You can delete a payment, but you can refund it.

=cut

sub del { ## no critic (RequireFinalReturn)
    Stancer::Exceptions::BadMethodCall->throw(
        message => 'You are not allowed to delete a payment, you need to refund it instead.',
    );
}

=method C<< $payment->is_success() : I<boolean> >>

=method C<< $payment->is_not_success() : I<boolean> >>

=method C<< $payment->is_error() : I<boolean> >>

=method C<< $payment->is_not_error() : I<boolean> >>

Indicates if payment is a success or not.

=cut

sub is_error {
    my $this = shift;
    my $yep = 1 == 1;
    my $nope = not $yep;

    return $nope unless defined $this->status;
    return $nope if $this->status eq Stancer::Payment::Status::CAPTURED;
    return $nope if $this->status eq Stancer::Payment::Status::CAPTURE_SENT;
    return $nope if $this->status eq Stancer::Payment::Status::TO_CAPTURE;
    return $nope if not($this->capture) && $this->status eq Stancer::Payment::Status::AUTHORIZED;
    return $yep;
}

sub is_not_error {
    my $this = shift;

    return !$this->is_error;
}

sub is_not_success {
    my $this = shift;

    return !$this->is_success;
}

sub is_success {
    my $this = shift;
    my $yep = 1 == 1;
    my $nope = not $yep;

    return $nope unless defined $this->status;
    return $yep if $this->status eq Stancer::Payment::Status::CAPTURED;
    return $yep if $this->status eq Stancer::Payment::Status::CAPTURE_SENT;
    return $yep if $this->status eq Stancer::Payment::Status::TO_CAPTURE;
    return $yep if not($this->capture) && $this->status eq Stancer::Payment::Status::AUTHORIZED;
    return $nope;
}

=method C<< Stancer::Payment->list(I<%terms>) : I<PaymentIterator> >>

=method C<< Stancer::Payment->list(I<\%terms>) : I<PaymentIterator> >>

List all payments.

C<%terms> must be an hash or a reference to an hash (C<\%terms>) with at least one of the following key :

=over

=item C<created>

Must be an unix timestamp, a C<DateTime> or a C<DateTime::Span> object which will filter payments created
after this value.
If a C<DateTime::Span> is passed, C<created_until> will be ignored and replaced with C<< DateTime::Span->end >>.

=item C<created_until>

Must be an unix timestamp or a C<DateTime> object which will filter payments created before this value.
If a C<DateTime::Span> is passed to C<created>, this value will be ignored.

=item C<limit>

Must be an integer between 1 and 100 and will limit the number of objects to be returned.
API defaults is to return 10 elements.

=item C<order_id>

Will filter payments corresponding to the C<order_id> you specified in your initial payment request.
Must be a string.

=item C<start>

Must be an integer and will be used as a pagination cursor, starts at 0.

=item C<unique_id>

Will filter payments corresponding to the C<unique_id> you specified in your initial payment request.
Must be a string.

=back

=cut

sub list {
    my ($class, @args) = @_;

    return Stancer::Core::Iterator::Payment->search(@args);
}

=method C<< $payment->payment_page_url() >>

=method C<< $payment->payment_page_url( I<%params> ) >>

=method C<< $payment->payment_page_url( I<\%params> ) >>

External URL for Stancer payment page.

Maybe used as an iframe or a redirection page if you needed it.

C<%terms> must be an hash or a reference to an hash (C<\%terms>) with at least one of the following key :

=over

=item C<lang>

To force the language of the page.

The page uses browser language as default language.
If no language available matches the asked one, the page will be shown in english.

=back

=method C<< Stancer::Payment->pay(I<$amount>, I<$currency>, I<$card>) >>

=method C<< Stancer::Payment->pay(I<$amount>, I<$currency>, I<$sepa>) >>

Quick way to make a simple payment.

=cut

sub pay {
    my $class = shift;
    my $amount = shift;
    my $currency = shift;
    my $means = shift;

    my $obj = $class->new(amount => $amount, currency => $currency);

    if (blessed($means) && $means->isa('Stancer::Card')) {
        $obj->card($means);
    }

    if (blessed($means) && $means->isa('Stancer::Sepa')) {
        $obj->sepa($means);
    }

    if (!$obj->card && !$obj->sepa) {
        Stancer::Exceptions::MissingPaymentMethod->throw();
    }

    return $obj->send();
}

=method C<< $payment->refund() : I<self> >>

=method C<< $payment->refund(I<$amount>) : I<self> >>

Refund a payment, or part of it.

I<$amount>, if provided, must be at least 50. If not present, all paid amount we be refund.

=cut

around send => sub {
    my ($orig, $this, $values) = @_;

    Stancer::Exceptions::InvalidAmount->throw() unless $this->amount;
    Stancer::Exceptions::InvalidCurrency->throw() unless $this->currency;

    if ($this->card && !$this->card->id) {
        my $exp = $this->card->expiration;

        Stancer::Exceptions::InvalidCardExpiration->throw() if $exp < DateTime->now()->truncate(to => 'month');
    }

    $this->_create_device;

    my $result = $this->$orig($values);
    my $message = sprintf 'Payment of %.2f %s without payment method', (
        $this->amount / 100,
        $this->currency,
    );

    if (defined $this->method && $this->method eq 'card') {
        $message = sprintf 'Payment of %.2f %s with %s "%s"', (
            $this->amount / 100,
            $this->currency,
            $this->card->brandname,
            $this->card->last4,
        );
    }

    if (defined $this->method && $this->method eq 'sepa') {
        $message = sprintf 'Payment of %.2f %s with IBAN "%s" / BIC "%s"', (
            $this->amount / 100,
            $this->currency,
            $this->sepa->last4,
            $this->sepa->bic,
        );
    }

    $log->info($message);

    return $result;
};

1;
