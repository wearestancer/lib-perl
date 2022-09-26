package Stancer::Exceptions::InvalidSearchLimit::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::InvalidSearchLimit;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(6) {
    my $object = Stancer::Exceptions::InvalidSearchLimit->new();

    isa_ok($object, 'Stancer::Exceptions::InvalidSearchLimit', 'Should return current instance');
    isa_ok($object, 'Stancer::Exceptions::InvalidSearchFilter', 'Should be a search filter exception');
    isa_ok($object, 'Stancer::Exceptions::InvalidArgument', 'Should be an invalid argument exception too');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Should be throwable');

    is($object->message, 'Limit must be between 1 and 100.', 'Has default message');
    is($object->log_level, 'debug', 'Has a log level');
}

1;
