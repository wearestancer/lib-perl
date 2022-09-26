package Stancer::Exceptions::MissingPaymentMethod::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::MissingPaymentMethod;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(5) {
    my $object = Stancer::Exceptions::MissingPaymentMethod->new();

    isa_ok($object, 'Stancer::Exceptions::MissingPaymentMethod', 'Should return current instance');
    isa_ok($object, 'Stancer::Exceptions::BadMethodCall', 'Should be a bad method call exception too');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Should be throwable');

    is($object->message, 'You must provide a valid credit card or SEPA account to make a payment.', 'Has default message');
    is($object->log_level, 'critical', 'Has a log level');
}

1;
