package Stancer::Core::Types::ApiKeys;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Internal ApiKeys types
# VERSION

our @EXPORT_OK = ();
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

use Stancer::Core::Types::Helper qw(error_message);

use namespace::clean;

use Exporter qw(import);

my @defs = ();

push @defs, {
    name => 'ApiKey',
    test => sub {
        my $value = shift;

        return if not defined $value;
        return if length $value != 30;

        ## no critic (RegularExpressions::RequireExtendedFormatting)
        $value =~ m/[sp](?:test|prod)_\w+/sm;
        ## use critic
    },
    message => error_message('%s is not a valid API key.'),
};

push @defs, {
    name => 'PublicLiveApiKey',
    subtype_of => 'ApiKey',
    from => __PACKAGE__,
    test => sub { $_[0] =~ m/^pprod_\w+/sm },
    message => error_message('%s is not a valid public API key for live mode.'),
};

push @defs, {
    name => 'PublicTestApiKey',
    subtype_of => 'ApiKey',
    from => __PACKAGE__,
    test => sub { $_[0] =~ m/^ptest_\w+/sm },
    message => error_message('%s is not a valid public API key for test mode.'),
};

push @defs, {
    name => 'SecretLiveApiKey',
    subtype_of => 'ApiKey',
    from => __PACKAGE__,
    test => sub { $_[0] =~ m/^sprod_\w+/sm },
    message => error_message('%s is not a valid secret API key for live mode.'),
};

push @defs, {
    name => 'SecretTestApiKey',
    subtype_of => 'ApiKey',
    from => __PACKAGE__,
    test => sub { $_[0] =~ m/^stest_\w+/sm },
    message => error_message('%s is not a valid secret API key for test mode.'),
};

Stancer::Core::Types::Helper::register_types(\@defs, __PACKAGE__);

1;
