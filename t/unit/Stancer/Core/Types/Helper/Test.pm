package Stancer::Core::Types::Helper::Test;

use 5.020;
use strict;
use warnings;
use base qw(Test::Class);

use Stancer::Core::Types::Helper qw(error_message);
use TestCase;

## no critic (RequireFinalReturn, RequireInterpolationOfMetachars)

sub message : Tests(6) {
    { # 2 tests
        note 'With string';

        my $arg = random_string(10);
        my $message = '%s';
        my $ret = error_message($message);

        is(ref $ret, 'CODE', 'Should retour a subroutine');
        is($ret->($arg), q/"/ . $arg . q/"/, 'Should output the message with a string argument');
    }

    { # 2 tests
        note 'With undef';

        my $message = '%s';
        my $ret = error_message($message);

        is(ref $ret, 'CODE', 'Should retour a subroutine');
        is($ret->(undef), 'undef', 'Should output the message with "undef" in it');
    }

    { # 2 tests
        note 'With multiple arguments';

        my $arg1 = random_string(10);
        my $arg2 = random_integer(10, 99);
        my $message = '%2$d %1$s';
        my $ret = error_message($message);

        is(ref $ret, 'CODE', 'Should retour a subroutine');
        is($ret->($arg1, $arg2), $arg2 . q/ "/ . $arg1 . q/"/, 'Should output the message with first arg with quote');
    }
}

1;
