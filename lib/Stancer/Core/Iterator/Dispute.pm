package Stancer::Core::Iterator::Dispute;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Iterate through disputes
# VERSION

use Stancer::Dispute;

use Moo;
use namespace::clean;

extends 'Stancer::Core::Iterator';


=head1 DESCRIPTION

You should not use this class directly.

This module is an internal class, regrouping method for every API object list.

=method C<< Stancer::Core::Iterator::Dispute->new(I<$sub>) : I<self> >>

Create a new iterator.

A subroutine, C<$sub> is mandatory, it will be used on every iteration.

=method C<< $iterator->next() : I<Dispute>|I<undef> >>

Return the next dispute object or C<undef> if no more element to iterate.

=cut

sub _create_element {
    my ($class, @args) = @_;

    return Stancer::Dispute->new(@args);
}

sub _element_key {
    return 'disputes';
}

=method C<< Stancer::Core::Iterator::Dispute->search(I<%terms>) : I<self> >>

=method C<< Stancer::Core::Iterator::Dispute->search(I<\%terms>) : I<self> >>

You may use L<Stancer::Dispute/list> instead.

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

    return $class->SUPER::search($params);
}

1;
