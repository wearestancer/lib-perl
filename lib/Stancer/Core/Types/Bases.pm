package Stancer::Core::Types::Bases;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Internal bases types
# VERSION

our @EXPORT_OK = ();
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

use Stancer::Core::Types::Helper qw(error_message);
use Stancer::Exceptions::InvalidArgument;
use List::Util qw(first);
use MooX::Types::MooseLike::Base qw();

use namespace::clean;

use Exporter qw(import);

my @defs = ();

push @defs, {
    name => 'Bool',
    subtype_of => 'Bool',
    from => 'MooX::Types::MooseLike::Base',
    test => sub { defined $_[0] },
    message => error_message('%s is not a bool.'),
    exception => 'Stancer::Exceptions::InvalidArgument',
};

push @defs, {
    name => 'Enum',
    test => sub {
        my ($value, @possible_values) = @_;

        return if not defined $value;
        return first { $value eq $_ } @possible_values;
    },
    message => sub {
        my ($value, @possible_values) = @_;

        my $message = 'Must be one of : %2$s. %1$s given'; ## no critic (RequireInterpolationOfMetachars)
        my $possible = join ', ', map { q/"/ . $_ . q/"/ } @possible_values;

        return error_message($message)->($value, $possible);
    },
    exception => 'Stancer::Exceptions::InvalidArgument',
};

push @defs, {
    name => 'InstanceOf',
    subtype_of => 'InstanceOf',
    from => 'MooX::Types::MooseLike::Base',
    test => sub { 1 },
    exception => 'Stancer::Exceptions::InvalidArgument',
};

push @defs, {
    name => 'Maybe',
    subtype_of => 'Maybe',
    from => 'MooX::Types::MooseLike::Base',
    test => sub { 1 },
    parameterizable => sub { return if not defined $_[0]; $_[0] },
};

push @defs, {
    name => 'Str',
    subtype_of => 'Str',
    from => 'MooX::Types::MooseLike::Base',
    test => sub { 1 },
    message => error_message('%s is not a string.'),
    exception => 'Stancer::Exceptions::InvalidArgument',
};

for my $name (qw(ArrayRef HashRef Int Num)) {
    push @defs, {
        name => $name,
        subtype_of => $name,
        from => 'MooX::Types::MooseLike::Base',
        test => sub { 1 }, # Just an alias
    };
}

Stancer::Core::Types::Helper::register_types(\@defs, __PACKAGE__);

1;
