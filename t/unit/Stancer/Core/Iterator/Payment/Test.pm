package Stancer::Core::Iterator::Payment::Test;
use base qw(Test::Class);

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Core::Iterator::Payment;
use TestCase;

sub instanciate : Tests(2) {
    my $object = Stancer::Core::Iterator::Payment->new();

    isa_ok($object, 'Stancer::Core::Iterator::Payment', 'Should return current instance');
    isa_ok($object, 'Stancer::Core::Iterator', 'Should be a child of Core::Iterator');
}

1;
