package Stancer::Exceptions::Throwable;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Base exception
# VERSION

use Moo;

with 'Throwable';

use namespace::clean;

=attr C<log_level>

Read-only string.

Indicate log level for this kind of exception.

=cut

has log_level => (
    is => 'ro',
    default => 'notice',
);

=attr C<message>

Read-only string.

Error message.

=cut

has message => (
    is => 'ro',
    default => 'Unexpected error.',
);

1;
