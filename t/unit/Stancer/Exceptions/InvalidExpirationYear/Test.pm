package Stancer::Exceptions::InvalidExpirationYear::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::InvalidExpirationYear;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(6) {
    my $object = Stancer::Exceptions::InvalidExpirationYear->new();

    isa_ok($object, 'Stancer::Exceptions::InvalidExpirationYear', 'Should return current instance');
    isa_ok($object, 'Stancer::Exceptions::InvalidCardExpiration', 'Should be an invalid card expiration exception');
    isa_ok($object, 'Stancer::Exceptions::InvalidArgument', 'Should be an invalid argument exception too');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Should be throwable');

    is($object->message, 'Expiration year is invalid.', 'Has default message');
    is($object->log_level, 'debug', 'Has a log level');
}

1;
