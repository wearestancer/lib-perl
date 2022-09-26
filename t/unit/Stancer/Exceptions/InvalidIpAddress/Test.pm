package Stancer::Exceptions::InvalidIpAddress::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::InvalidIpAddress;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(5) {
    my $object = Stancer::Exceptions::InvalidIpAddress->new();

    isa_ok($object, 'Stancer::Exceptions::InvalidIpAddress', 'Should return current instance');
    isa_ok($object, 'Stancer::Exceptions::InvalidArgument', 'Should be an invalid argument exception too');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Should be throwable');

    is($object->message, 'Invalid IP address.', 'Has default message');
    is($object->log_level, 'debug', 'Has a log level');
}

1;
