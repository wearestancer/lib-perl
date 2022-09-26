package Stancer::Core::Types::Dates;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Internal dates types
# VERSION

our @EXPORT_OK = ();
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

use Stancer::Core::Types::Bases qw();
use Stancer::Core::Types::Helper qw(error_message);
use Stancer::Exceptions::InvalidExpirationMonth;
use Stancer::Exceptions::InvalidExpirationYear;
use List::MoreUtils qw(any);

use namespace::clean;

use Exporter qw(import);

my @defs = ();

push @defs, {
    name => 'Month',
    subtype_of => 'Int',
    from => 'Stancer::Core::Types::Bases',
    test => sub { 1 <= $_[0] && $_[0] <= 12 },
    message => error_message('Must be an integer between 1 and 12 (included), %s given.'),
    exception => 'Stancer::Exceptions::InvalidExpirationMonth',
};

push @defs, {
    name => 'Year',
    subtype_of => 'Int',
    from => 'Stancer::Core::Types::Bases',
    test => sub { 1 },
    message => error_message('Must be an integer, %s given.'),
    exception => 'Stancer::Exceptions::InvalidExpirationYear',
};

Stancer::Core::Types::Helper::register_types(\@defs, __PACKAGE__);

1;
