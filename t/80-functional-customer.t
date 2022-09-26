#! /usr/bin/env perl

use 5.020;
use strict;
use warnings;

BEGIN {
    ## no critic (ProhibitUnlessBlocks, RequireCheckedSyscalls)
    unless ($ENV{AUTHOR_TESTING}) {
        print qq{1..0 # SKIP these tests are for testing by the author\n};
        exit
    }

    unless ($ENV{API_KEY} && $ENV{API_HOST}) {
        print qq{1..0 # SKIP these tests need configuration\n};
        exit
    }
    ## use critic
}

use lib './t/unit';
use Stancer::Config;
use Stancer::Customer::Test::Functional;

my $config = Stancer::Config->init($ENV{API_KEY});

$config->host($ENV{API_HOST});
$config->lwp(LWP::UserAgent->new(ssl_opts => {SSL_ca_path=>'/etc/ssl/certs'}));

Test::Class->runtests;
