package Stancer::Core::Types::Bank;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Internal Bank types
# VERSION

our @EXPORT_OK = ();
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

use Business::IBAN;
use Business::SWIFT;
use Stancer::Core::Types::Helper qw(error_message);
use Stancer::Exceptions::InvalidAmount;
use Stancer::Exceptions::InvalidBic;
use Stancer::Exceptions::InvalidCardNumber;
use Stancer::Exceptions::InvalidCardVerificationCode;
use Stancer::Exceptions::InvalidCurrency;
use Stancer::Exceptions::InvalidIban;
use List::MoreUtils qw(any);
use List::Util qw(sum);

use namespace::clean;

use Exporter qw(import);

my @defs = ();
my @allowed_currencies = qw(aud cad chf dkk eur gbp jpy nok pln sek usd);

# Amount & currencies
push @defs, {
    name => 'Amount',
    test => sub {
        my $value = shift;

        return if not defined $value;
        return if $value !~ m/^\d+$/sm;
        return if $value < 50;
        return 1;
    },
    message => error_message('Amount must be an integer and at least 50, %s given.'),
    exception => 'Stancer::Exceptions::InvalidAmount',
};

push @defs, {
    name => 'Currency',
    test => sub {
        my $value = shift;

        return if not defined $value;
        return any { $_ eq lc $value } @allowed_currencies;
    },
    message => error_message('Currency must be one of "' . join('", "', @allowed_currencies) . '", %s given.'),
    exception => 'Stancer::Exceptions::InvalidCurrency',
};

# Cards
push @defs, {
    name => 'CardNumber',
    test => sub {
        my $value = shift;

        return if not defined $value;
        return if $value !~ m/^\d+$/sm;

        my @numbers = split //sm, $value;
        my @calc = qw(0 2 4 6 8 1 3 5 7 9);
        my $index = 0;

        my @translated = map { $index++ % 2 ? $calc[$_] : int } reverse @numbers;

        return sum(@translated) % 10 == 0;
    },
    message => error_message('%s is not a valid credit card number.'),
    exception => 'Stancer::Exceptions::InvalidCardNumber',
};

push @defs, {
    name => 'CardVerificationCode',
    test => sub {
        my $value = shift;

        return if not defined $value;
        return if $value !~ m/^\d+$/sm;
        return if length $value != 3;

        return 1;
    },
    message => error_message('%s is not a valid card verification code.'),
    exception => 'Stancer::Exceptions::InvalidCardVerificationCode',
};

# SEPA
push @defs, {
    name => 'Bic',
    test => sub {
        my $value = shift;

        return if not defined $value;
        return Business::SWIFT->validateBIC($value);
    },
    message => error_message('%s is not a valid BIC code.'),
    exception => 'Stancer::Exceptions::InvalidBic',
};

push @defs, {
    name => 'Iban',
    test => sub {
        my $value = shift;

        return if not defined $value;
        return Business::IBAN->new()->valid($value);
    },
    message => error_message('%s is not a valid IBAN account.'),
    exception => 'Stancer::Exceptions::InvalidIban',
};

Stancer::Core::Types::Helper::register_types(\@defs, __PACKAGE__);

1;
