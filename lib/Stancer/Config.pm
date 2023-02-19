package Stancer::Config;

use 5.020;
use strict;
use warnings;

# ABSTRACT: API configuration
# VERSION

use Stancer::Core::Types qw(:api ArrayRef Bool Enum InstanceOf Int Port Str);

use Config qw(%Config);
use DateTime::TimeZone;
use English qw(-no_match_vars);
use Stancer::Exceptions::MissingApiKey;
use LWP::UserAgent;
use Scalar::Util qw(blessed);

use Moo;
use namespace::clean;

use constant {
    LIVE => 'live',
    TEST => 'test',
};

=head1 SYNOPSIS

Handle configuration, connection and credential to API.

    use Stancer::Config;

    Stancer::Config->init($secret_key);

    my $payment = Stancer::Payment->new();
    $payment->send();

=method C<< Stancer::Config->new(I<%args>) : I<self> >>

This method create a new configuration object.
C<%args> can have any attribute listed in current documentation.

We may also see L</init> method.

=cut

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;
    my $params = $class->$orig(@args);

    if (exists $params->{keychain}) {
        my @keys = $params->{keychain};

        @keys = @{$params->{keychain}} if ref $params->{keychain} eq 'ARRAY';

        foreach my $key (@keys) {
            my $prefix = substr $key, 0, 5;

            $params->{pprod} = $key if $prefix eq 'pprod';
            $params->{ptest} = $key if $prefix eq 'ptest';
            $params->{sprod} = $key if $prefix eq 'sprod';
            $params->{stest} = $key if $prefix eq 'stest';
        }
    }

    return $params;
};

=attr C<calls>

Read-only list of C<Stancer::Core::Request::Call>.

This list is only available in debug mode.

=cut

has calls => (
    is => 'ro',
    isa => ArrayRef[InstanceOf['Stancer::Core::Request::Call']],
    default => sub { [] },
);

=attr C<debug>

Read/Write boolean.

Indicate if we are in debug mode.

In debug mode we will register every request made to the API.

Debug mode is enabled by default in test mode and disabled by default in live mode.

=cut

has debug => (
    is => 'rw',
    isa => Bool,
    default => sub { not(defined $_[0]->mode) or $_[0]->mode ne Stancer::Config::LIVE },
    lazy => 1,
);

=attr C<default_timezone>

Read/Write instance of C<DateTime::TimeZone>.

Will be used as default time zone for every C<DateTime> object created by the API.

If none provided, we will let
L<DateTime default mechanism|https://metacpan.org/pod/DateTime#Globally-Setting-a-Default-Time-Zone>
do the work.

You may pass a string, it will be used to create a new C<DateTime::TimeZone> instance.

=cut

has default_timezone => (
    is => 'rw',
    isa => InstanceOf['DateTime::TimeZone'],
    coerce => sub {
        return $_[0] if not defined $_[0];
        return $_[0] if blessed($_[0]) and $_[0]->isa('DateTime::TimeZone');
        return DateTime::TimeZone->new(name => $_[0]);
    },
);

=attr C<host>

Read/Write string, default to "api.stancer.com".

API host

=cut

has host => (
    is => 'rw',
    isa => Str,
    default => 'api.stancer.com',
    predicate => 1,
);

=attr C<keychain>

Read/Write array reference of API keys.

API keychain.

=cut

sub keychain {
    my ($this, @args) = @_;
    my @data = @args;
    my @keychain = ();

    if (scalar @args == 1) {
        if (ref $args[0] eq 'ARRAY') {
            @data = @{$args[0]};
        } else {
            @data = ($args[0]);
        }
    }

    if (@data) {
        foreach my $key (@data) {
            ApiKey->($key); # Automaticaly throw an error if $key has a bad format

            my $prefix = substr $key, 0, 5;

            $this->pprod($key) if $prefix eq 'pprod';
            $this->ptest($key) if $prefix eq 'ptest';
            $this->sprod($key) if $prefix eq 'sprod';
            $this->stest($key) if $prefix eq 'stest';
        }
    }

    push @keychain, $this->pprod if defined $this->pprod;
    push @keychain, $this->ptest if defined $this->ptest;
    push @keychain, $this->sprod if defined $this->sprod;
    push @keychain, $this->stest if defined $this->stest;

    return \@keychain;
}

=attr C<lwp>

Read/Write instance of C<LWP::UserAgent>.

If none provided, it will instanciate a new instance.
This allow you to provide your own configured L<LWP::UserAgent>.

=cut

has lwp => (
    is => 'rw',
    isa => sub { ref $_[0] eq 'LWP::UserAgent' },
    default => sub { LWP::UserAgent->new() },
    lazy => 1,
    predicate => 1,
);

=attr C<mode>

Read/Write, must be 'test' or 'live', default depends on key.

You better use `Stancer::Config::TEST` or `Stancer::Config::LIVE` constants.

API mode

=cut

has mode => (
    is => 'rw',
    isa => Enum[TEST, LIVE],
    default => TEST,
    predicate => 1,
);

=attr C<port>

Read/Write integer.

API HTTP port

=cut

has port => (
    is => 'rw',
    isa => Port,
    predicate => 1,
);

=attr C<pprod>

Read/Write 30 characters string.

Public production authentication key.

=cut

has pprod => (
    is => 'rw',
    isa => PublicLiveApiKey,
);

=attr C<public_key>

Read-only 30 characters string.

Public authentication key.
Will return C<pprod> or C<ptest> key depending on configured C<mode>.

=cut

sub public_key {
    my $this = shift;
    my $key = $this->ptest;
    my $message = 'You did not provide valid public API key for %s.';
    my $environment = 'development';

    if ($this->is_live_mode) {
        $key = $this->pprod;
        $environment = 'production';
    }

    Stancer::Exceptions::MissingApiKey->throw(message => sprintf $message, $environment) unless defined $key;

    return $key;
}

=attr C<ptest>

Read/Write 30 characters string.

Public development authentication key.

=cut

has ptest => (
    is => 'rw',
    isa => PublicTestApiKey,
);

=attr C<secret_key>

Read-only 30 characters string.

Secret authentication key.
Will return C<sprod> or C<stest> key depending on configured C<mode>.

=cut

sub secret_key {
    my $this = shift;
    my $key = $this->stest;
    my $message = 'You did not provide valid secret API key for %s.';
    my $environment = 'development';

    if ($this->is_live_mode) {
        $key = $this->sprod;
        $environment = 'production';
    }

    Stancer::Exceptions::MissingApiKey->throw(message => sprintf $message, $environment) unless defined $key;

    return $key;
}

=attr C<sprod>

Read/Write 30 characters string.

Secret production authentication key.

=cut

has sprod => (
    is => 'rw',
    isa => SecretLiveApiKey,
);

=attr C<stest>

Read/Write 30 characters string.

Secret development authentication key.

=cut

has stest => (
    is => 'rw',
    isa => SecretTestApiKey,
);

=attr C<timeout>

Read/Write integer, default 5.

Timeout for every API call

=cut

has timeout => (
    is => 'rw',
    isa => Int,
    default => 5,
    predicate => 1,
);

=attr C<uri>

Read-only string.

Complete location for the API.

=cut

sub uri {
    my $this = shift;
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    my $pattern = 'https://%1$s/v%3$s';

    if ($this->port) {
        $pattern = 'https://%1$s:%2$d/v%3$s';
    }
    ## use critic

    return sprintf $pattern, $this->host, $this->port, $this->version;
}

=attr C<user_agent>

Read-only default user agent.

=cut

sub user_agent {
    return sprintf 'libwww-perl/%s libstancer-perl/%s (%s %s; perl %vd)', (
        $LWP::VERSION,
        $Stancer::Config::VERSION,
        $Config{osname},
        $Config{archname},
        $PERL_VERSION,
    );
}

=attr C<version>

Read/Write integer.

API version

=cut

has version => (
    is => 'rw',
    isa => Int,
    default => 1,
    predicate => 1,
);

=method C<< Config::init(I<$token>) : I<self> >>

=method C<< Config::init(I<%args>) : I<self> >>

=method C<< Config::init() : I<self> >>

Get an instance with only a token. It may also accept the same hash used in `new` method.

Will act as a singleton if called without argument.

=cut

my $instance;

sub init {
    my ($self, @args) = @_;

    if ($self && $self ne __PACKAGE__) {
        unshift @args, $self;
    }

    my $params = {};

    if (scalar @args == 0) {
        return $instance;
    }

    if (scalar @args == 1) {
        if (ref $args[0] eq 'HASH') {
            $params = $args[0];
        } else {
            $params->{keychain} = $args[0];
        }
    } else {
        $params = {@args};
    }

    $instance = __PACKAGE__->new($params);

    return $instance;
}

=method C<< $config->is_live_mode() : I<bool> >>

=method C<< $config->is_test_mode() : I<bool> >>

=method C<< $config->is_not_live_mode() : I<bool> >>

=method C<< $config->is_not_test_mode() : I<bool> >>

Indicate if we are running or not is live mode or test mode.

=cut

sub is_live_mode {
    my $this = shift;

    return 1 if $this->mode eq LIVE;
    return q//;
}

sub is_test_mode {
    my $this = shift;

    return 1 if $this->mode eq TEST;
    return q//;
}

sub is_not_live_mode {
    my $this = shift;

    return not $this->is_live_mode;
}

sub is_not_test_mode {
    my $this = shift;

    return not $this->is_test_mode;
}

=method C<< $config->last_call() : I<Stancer::Core::Request::Call> >>

Return the last call to the API.

=cut

sub last_call {
    my $this = shift;

    return ${ $this->calls }[-1];
}

1;
