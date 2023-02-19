package Stancer;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Stancer Perl library
# VERSION

use namespace::clean;

use Stancer::Auth;
use Stancer::Card;
use Stancer::Config;
use Stancer::Customer;
use Stancer::Device;
use Stancer::Dispute;
use Stancer::Payment::Status;
use Stancer::Refund;
use Stancer::Sepa;

=head1 SYNOPSIS

    Stancer::Config->init($secret_key);

    my $payment = Stancer::Payment->new(amount => 100, currency = 'eur');
    $payment->send();


=head1 DESCRIPTION

This module provides common bindings for the Stancer API.

Every API object has a module representation:

=over

=item L<Auth|Stancer::Auth>

=item L<Card|Stancer::Card>

=item L<Customer|Stancer::Customer>

=item L<Device|Stancer::Device>

=item L<Dispute|Stancer::Dispute>

=item L<Payment|Stancer::Payment>

=item L<Refund|Stancer::Refund>

=item L<Sepa|Stancer::Sepa>

=back


=head1 REPOSITORY

L<https://gitlab.com/wearestancer/library/lib-perl>


=head1 SEE ALSO

Documentation L<http://stancer.com/documentation/>

=cut

1;
