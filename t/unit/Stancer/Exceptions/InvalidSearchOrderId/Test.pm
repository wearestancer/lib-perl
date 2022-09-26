package Stancer::Exceptions::InvalidSearchOrderId::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::InvalidSearchOrderId;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(6) {
    my $object = Stancer::Exceptions::InvalidSearchOrderId->new();

    isa_ok($object, 'Stancer::Exceptions::InvalidSearchOrderId', 'Should return current instance');
    isa_ok($object, 'Stancer::Exceptions::InvalidSearchFilter', 'Should be a search filter exception');
    isa_ok($object, 'Stancer::Exceptions::InvalidArgument', 'Should be an invalid argument exception too');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Should be throwable');

    is($object->message, 'Invalid order ID.', 'Has default message');
    is($object->log_level, 'debug', 'Has a log level');
}

1;
