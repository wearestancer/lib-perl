package Stancer::Exceptions::InvalidSearchCreation::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Exceptions::InvalidSearchCreation;
use TestCase;

## no critic (RequireFinalReturn)

sub instance : Tests(6) {
    my $object = Stancer::Exceptions::InvalidSearchCreation->new();

    isa_ok($object, 'Stancer::Exceptions::InvalidSearchCreation', 'Stancer::Exceptions::InvalidSearchCreation->new()');
    isa_ok($object, 'Stancer::Exceptions::InvalidSearchFilter', 'Stancer::Exceptions::InvalidSearchCreation->new()');
    isa_ok($object, 'Stancer::Exceptions::InvalidArgument', 'Stancer::Exceptions::InvalidSearchCreation->new()');
    isa_ok($object, 'Stancer::Exceptions::Throwable', 'Stancer::Exceptions::InvalidSearchCreation->new()');

    is($object->message, 'Created must be a position integer or a DateTime object and must be in the past.', 'Has default message');
    is($object->log_level, 'debug', 'Has a log level');
}

1;
