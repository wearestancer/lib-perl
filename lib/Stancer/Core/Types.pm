package Stancer::Core::Types;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Internal types
# VERSION

use base qw(Exporter);
our @EXPORT_OK = ();

use namespace::clean;

use Exporter qw(import);
use Stancer::Core::Types::ApiKeys qw(:all);
use Stancer::Core::Types::Bank qw(:all);
use Stancer::Core::Types::Bases qw(:all);
use Stancer::Core::Types::Dates qw(:all);
use Stancer::Core::Types::Helper qw(:all);
use Stancer::Core::Types::Network qw(:all);
use Stancer::Core::Types::Object qw(:all);
use Stancer::Core::Types::String qw(:all);

our %EXPORT_TAGS = (
    all => \@EXPORT_OK,
    api => \@Stancer::Core::Types::ApiKeys::EXPORT_OK,
    bank => \@Stancer::Core::Types::Bank::EXPORT_OK,
    bases => \@Stancer::Core::Types::Bases::EXPORT_OK,
    dates => \@Stancer::Core::Types::Dates::EXPORT_OK,
    helper => \@Stancer::Core::Types::Helper::EXPORT_OK,
    network => \@Stancer::Core::Types::Network::EXPORT_OK,
    object => \@Stancer::Core::Types::Object::EXPORT_OK,
    str => \@Stancer::Core::Types::String::EXPORT_OK,
);

push @EXPORT_OK, map { @{$_} } values %EXPORT_TAGS;

1;
