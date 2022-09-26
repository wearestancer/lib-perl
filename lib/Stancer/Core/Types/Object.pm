package Stancer::Core::Types::Object;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Internal object types
# VERSION

our @EXPORT_OK = ();
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

use Stancer::Core::Types::Helper qw(create_instance_type);
use Stancer::Exceptions::InvalidAuthInstance;
use Stancer::Exceptions::InvalidCardInstance;
use Stancer::Exceptions::InvalidCustomerInstance;
use Stancer::Exceptions::InvalidDeviceInstance;
use Stancer::Exceptions::InvalidPaymentInstance;
use Stancer::Exceptions::InvalidRefundInstance;
use Stancer::Exceptions::InvalidSepaInstance;
use Stancer::Exceptions::InvalidSepaCheckInstance;

use namespace::clean;

use Exporter qw(import);

my @defs = ();

for my $name (qw(Auth Card Customer Device Payment Refund Sepa Sepa::Check)) {
    push @defs, create_instance_type($name);
}

Stancer::Core::Types::Helper::register_types(\@defs, __PACKAGE__);

1;
