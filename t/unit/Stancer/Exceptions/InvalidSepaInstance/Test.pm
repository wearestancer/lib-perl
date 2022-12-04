package Stancer::Exceptions::InvalidSepaInstance::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::InvalidSepaInstance;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(5) {
    my $object = Stancer::Exceptions::InvalidSepaInstance->new();

    isa_ok($object, 'Stancer::Exceptions::InvalidSepaInstance', 'Stancer::Exceptions::InvalidSepaInstance->new()');
    isa_ok($object, 'Stancer::Exceptions::InvalidArgument', 'Stancer::Exceptions::InvalidSepaInstance->new()');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Stancer::Exceptions::InvalidSepaInstance->new()');

    is($object->message, 'Invalid Sepa instance.', 'Has default message');
    is($object->log_level, 'debug', 'Has a log level');
}

1;
