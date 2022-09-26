package Stancer::Card;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Card representation
# VERSION

use Stancer::Core::Types qw(coerce_boolean Bool CardNumber CardVerificationCode Char Maybe Month Str Year);

use Stancer::Exceptions::InvalidExpirationMonth;
use Stancer::Exceptions::InvalidExpirationYear;
use List::MoreUtils qw(any);

use Moo;
use namespace::clean;

extends 'Stancer::Core::Object';
with 'Stancer::Role::Country', 'Stancer::Role::Name';

has '+_boolean' => (
    default => sub{ [qw(tokenize)] },
);

has '+endpoint' => (
    default => 'cards',
);

has '+_integer' => (
    default => sub{ [qw(exp_month exp_year)] },
);

has '+_json_ignore' => (
    default => sub{ [qw(endpoint created populated brand country last4)] },
);

=method C<< Stancer::Card->new() : I<self> >>

=method C<< Stancer::Card->new(I<$token>) : I<self> >>

=method C<< Stancer::Card->new(I<%args>) : I<self> >>

=method C<< Stancer::Card->new(I<\%args>) : I<self> >>

This method accept an optional string, it will be used as an entity ID for API calls.

    # Get an empty new card
    my $new = Stancer::Card->new();

    # Get an existing card
    my $exist = Stancer::Card->new($token);

=attr C<brand>

Read-only string.

Card brand name

=cut

has brand => (
    is => 'rwp',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('brand') },
    lazy => 1,
    predicate => 1,
);

=attr C<brandname>

Read-only string.

Card real brand name.

Whereas C<brand> returns brand as a simple normalized string like "amex",
C<brandname> will return a complete and real brand name, like "American Express".

=cut

my %names = (
    amex => 'American Express',
    dankort => 'Dankort',
    discover => 'Discover',
    jcb => 'JCB',
    maestro => 'Maestro',
    mastercard => 'MasterCard',
    visa => 'VISA',
);

sub brandname {
    my $this = shift;
    my $brand = $this->brand;

    return if not defined $brand;
    return $names{$brand} if any { $_ eq $brand } keys %names;
    return $brand;
}

=attr C<country>

Read-only string.

Card country

=attr C<cvc>

Read/Write 3 characters string.

Card verification code

=cut

has cvc => (
    is => 'rw',
    isa => Maybe[CardVerificationCode],
    builder => sub { $_[0]->_attribute_builder('cvc') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('cvc') },
);

=attr C<expiration>

Read-only C<DateTime>.

Expiration date as a C<DateTime> object.

=cut

sub expiration {
    my $this = shift;
    my $year = $this->exp_year;
    my $month = $this->exp_month;
    my $message = 'You must set an expiration %s before asking for a date.';

    Stancer::Exceptions::InvalidExpirationMonth->throw(message => sprintf $message, 'month') if not defined $month;
    Stancer::Exceptions::InvalidExpirationYear->throw(message => sprintf $message, 'year') if not defined $year;

    return DateTime->last_day_of_month(year => $year, month => $month);
}

=attr C<exp_month>

Read/Write integer.

Expiration month

=cut

has exp_month => (
    is => 'rw',
    isa => Maybe[Month],
    builder => sub { $_[0]->_attribute_builder('exp_month') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('exp_month') },
);

=attr C<exp_year>

Read/Write integer.

Expiration year

=cut

has exp_year => (
    is => 'rw',
    isa => Maybe[Year],
    builder => sub { $_[0]->_attribute_builder('exp_year') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('exp_year') },
);

=attr C<funding>

Read-only string or undefined.

Type of funding

Should be one of "credit", "debit", "prepaid", "universal", "charge", "deferred".
May be undefined when the type could not be determined.

=cut

has funding => (
    is => 'rwp',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('funding') },
    lazy => 1,
    predicate => 1,
);

=attr C<last4>

Read-only 4 characters string.

Last four card number

=cut

has last4 => (
    is => 'rwp',
    isa => Maybe[Char[4]],
    builder => sub { $_[0]->_attribute_builder('last4') },
    lazy => 1,
    predicate => 1,
);

=attr C<name>

Read/Write 4 to 64 characters string.

Card holder's name

=attr C<nature>

Read-only string or undefined.

Nature of the card

Should be "personnal" or "corporate".
May be undefined when the nature could not be determined.

=cut

has nature => (
    is => 'rwp',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('nature') },
    lazy => 1,
    predicate => 1,
);

=attr C<network>

Read-only string or undefined.

Nature of the card

Should be "mastercard", "national" or "visa".
May be undefined when the network could not be determined.

=cut

has network => (
    is => 'rwp',
    isa => Maybe[Str],
    builder => sub { $_[0]->_attribute_builder('network') },
    lazy => 1,
    predicate => 1,
);

=attr C<number>

Read/Write 16 to 19 characters string.

Card number

=cut

has number => (
    is => 'rw',
    isa => Maybe[CardNumber],
    predicate => 1,
    trigger => sub {
        my $this = shift;
        my $number = shift;
        my $last4 = substr $number, -4;

        $this->_add_modified('number');
        $this->_set_last4($last4);
    },
);

=attr C<tokenize>

Read/Write boolean.

Save card for later use

=cut

has tokenize => (
    is => 'rw',
    isa => Maybe[Bool],
    builder => sub { $_[0]->_attribute_builder('tokenize') },
    coerce  => coerce_boolean(),
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('tokenize') },
);

1;
