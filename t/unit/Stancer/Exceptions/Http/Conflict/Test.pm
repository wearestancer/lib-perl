package Stancer::Exceptions::Http::Conflict::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::Http::Conflict;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(7) {
    my $object = Stancer::Exceptions::Http::Conflict->new();

    isa_ok($object, 'Stancer::Exceptions::Http::Conflict', 'Should return current instance');
    isa_ok($object, 'Stancer::Exceptions::Http::ClientSide', 'Should be a client side exception');
    isa_ok($object, 'Stancer::Exceptions::Http', 'Should be an HTTP exception');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Should be throwable');

    is($object->message, 'Conflict', 'Has default message');
    is($object->log_level, 'error', 'Has a log level');
    is($object->status, 409, 'Has an HTTP status');
}

1;
