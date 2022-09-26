package Stancer::Core::Types::Network;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Internal network types
# VERSION

our @EXPORT_OK = ();
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

use Stancer::Core::Types::Helper qw(error_message);
use Stancer::Exceptions::InvalidIpAddress;
use Stancer::Exceptions::InvalidPort;
use Stancer::Exceptions::InvalidUrl;
use MooX::Types::MooseLike::Base qw();
use Socket qw(AF_INET AF_INET6 inet_pton);

use namespace::clean;

use Exporter qw(import);

my @defs = ();

push @defs, {
    name => 'IpAddress',
    test => sub {
        my $value = shift;

        return 0 if not defined $value;
        return 1 if defined inet_pton(AF_INET, $value);
        return 1 if defined inet_pton(AF_INET6, $value);
        return 0;
    },
    message => error_message('%s is not a valid IP address.'),
    exception => 'Stancer::Exceptions::InvalidIpAddress',
};

push @defs, {
    name => 'Port',
    subtype_of => 'Int',
    from => 'MooX::Types::MooseLike::Base',
    test => sub { $_[0] > 0 && $_[0] <= 65_535 },
    message => error_message('Must be at less than 65535, %s given.'),
    exception => 'Stancer::Exceptions::InvalidPort',
};

push @defs, {
    name => 'Url',
    test => sub {
        my $value = shift;

        return 0 if not defined $value;
        return $value =~ /^https:\/\//smx;
    },
    message => error_message('%s is not a valid HTTPS url.'),
    exception => 'Stancer::Exceptions::InvalidUrl',
};

Stancer::Core::Types::Helper::register_types(\@defs, __PACKAGE__);

1;
