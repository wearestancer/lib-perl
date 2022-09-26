package Stancer::Exceptions::InvalidSearchStart::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::InvalidSearchStart;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(6) {
    my $object = Stancer::Exceptions::InvalidSearchStart->new();

    isa_ok($object, 'Stancer::Exceptions::InvalidSearchStart', 'Should return current instance');
    isa_ok($object, 'Stancer::Exceptions::InvalidSearchFilter', 'Should be a search filter exception');
    isa_ok($object, 'Stancer::Exceptions::InvalidArgument', 'Should be an invalid argument exception too');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Should be throwable');

    is($object->message, 'Start must be a positive integer.', 'Has default message');
    is($object->log_level, 'debug', 'Has a log level');
}

1;
