package Stancer::Exceptions::Http::Unauthorized::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::Http::Unauthorized;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(7) {
    my $object = Stancer::Exceptions::Http::Unauthorized->new();

    isa_ok($object, 'Stancer::Exceptions::Http::Unauthorized', 'Should return current instance');
    isa_ok($object, 'Stancer::Exceptions::Http::ClientSide', 'Should be a client side exception');
    isa_ok($object, 'Stancer::Exceptions::Http', 'Should be an HTTP exception');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Should be throwable');

    is($object->message, 'Unauthorized', 'Has default message');
    is($object->log_level, 'critical', 'Has a log level');
    is($object->status, 401, 'Has an HTTP status');
}

1;
