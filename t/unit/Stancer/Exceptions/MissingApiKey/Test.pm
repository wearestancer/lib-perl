package Stancer::Exceptions::MissingApiKey::Test;

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::MissingApiKey;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(5) {
    my $object = Stancer::Exceptions::MissingApiKey->new();

    isa_ok($object, 'Stancer::Exceptions::MissingApiKey', 'Should return current instance');
    isa_ok($object, 'Stancer::Exceptions::BadMethodCall', 'Should be a bad method call exception too');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Should be throwable');

    is($object->message, 'You did not provide valid API key.', 'Has default message');
    is($object->log_level, 'critical', 'Has a log level');
}

1;
