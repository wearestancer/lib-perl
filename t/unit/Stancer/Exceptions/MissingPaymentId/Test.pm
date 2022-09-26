package Stancer::Exceptions::MissingPaymentId::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::MissingPaymentId;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(5) {
    my $object = Stancer::Exceptions::MissingPaymentId->new();

    isa_ok($object, 'Stancer::Exceptions::MissingPaymentId', 'Should return current instance');
    isa_ok($object, 'Stancer::Exceptions::BadMethodCall', 'Should be a bad method call exception too');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Should be throwable');

    is($object->message, 'A payment ID is mandatory. Maybe you forgot to send the payment.', 'Has default message');
    is($object->log_level, 'critical', 'Has a log level');
}

1;
