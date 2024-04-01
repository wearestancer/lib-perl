package Stancer::Core::Iterator::Payment;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Iterate through payments
# VERSION

use Stancer::Exceptions::InvalidSearchOrderId;
use Stancer::Exceptions::InvalidSearchUniqueId;
use Stancer::Payment;

use Moo;

extends 'Stancer::Core::Iterator';

use namespace::clean;

=head1 DESCRIPTION

You should not use this class directly.

This module is an internal class, regrouping method for every API object list.

=method C<< Stancer::Core::Iterator::Payment->new(I<$sub>) : I<self> >>

Create a new iterator.

A subroutine, C<$sub> is mandatory, it will be used on every iteration.

=method C<< $iterator->next() : I<Payment>|I<undef> >>

Return the next payment object or C<undef> if no more element to iterate.

=cut

sub _create_element {
    my ($class, @args) = @_;

    return Stancer::Payment->new(@args);
}

sub _element_key {
    return 'payments';
}

=method C<< Stancer::Core::Iterator::Payment->search(I<%terms>) : I<self> >>

=method C<< Stancer::Core::Iterator::Payment->search(I<\%terms>) : I<self> >>

You may use L<Stancer::Payment/list> instead.

=cut

sub search {
    my ($class, @args) = @_;
    my $data;
    my $params = {};

    if (scalar @args == 1) {
        $data = $args[0];
    } else {
        $data = {@args};
    }

    $params->{created} = $class->_search_filter_created($data) if defined $data->{created};
    $params->{created_until} = $class->_search_filter_created_until($data) if defined $data->{created_until};
    $params->{limit} = $class->_search_filter_limit($data) if defined $data->{limit};
    $params->{start} = $class->_search_filter_start($data) if defined $data->{start};

    $params->{order_id} = $class->_search_filter_order_id($data) if defined $data->{order_id};
    $params->{unique_id} = $class->_search_filter_unique_id($data) if defined $data->{unique_id};

    return $class->SUPER::search($params);
}

sub _search_filter_order_id {
    my ($class, $data) = @_;
    my $len = length $data->{order_id};

    if ($len > 36) {
        my $message = 'Invalid order ID.';

        Stancer::Exceptions::InvalidSearchOrderId->throw(message => $message);
    }

    return $data->{order_id};
}

sub _search_filter_unique_id {
    my ($class, $data) = @_;
    my $len = length $data->{unique_id};

    Stancer::Exceptions::InvalidSearchUniqueId->throw() if $len > 36;

    return $data->{unique_id};
}

1;
