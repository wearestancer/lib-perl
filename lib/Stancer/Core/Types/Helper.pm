package Stancer::Core::Types::Helper;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Internal types helpers
# VERSION

use DateTime;
use Scalar::Util qw(blessed);
use MooX::Types::MooseLike qw();

use namespace::clean;

use Exporter qw(import);

our @EXPORT_OK = qw(coerce_boolean coerce_date coerce_datetime coerce_instance create_instance_type error_message);
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

=head1 FUNCTIONS

=head2 C<< coerce_boolean() : I<CODE> >>

Helper function for C<Bool> type attribute.

=cut

sub coerce_boolean {
    return sub {
        my $value = shift;

        return if not defined $value;
        return 1 if "$value" eq 'true';
        return 0 if "$value" eq 'false';
        return $value;
    };
}

=head2 C<< coerce_date() : I<CODE> >>

Helper function for C<DateTime> type attribute.

=cut

sub coerce_date {
    return sub {
        my $value = shift;

        return unless defined $value;
        return $value->clone()->truncate(to => 'day') if blessed($value) and (blessed($value) eq 'DateTime');

        my ($y, $m, $d) = split qr/-/sm, $value;

        if (defined $d) {
            return DateTime->new(year => $y, month => $m, day => $d);
        }

        return DateTime->from_epoch(epoch => $value);
    };
}

=head2 C<< coerce_datetime() : I<CODE> >>

Helper function for C<DateTime> type attribute.

=cut

sub coerce_datetime {
    return sub {
        my $value = shift;
        my $config = Stancer::Config->init();
        my %data = (
            epoch => $value,
        );

        if (defined $config->default_timezone) {
            $data{time_zone} = $config->default_timezone;
        }

        return unless defined $value;
        return $value if blessed($value) and (blessed($value) eq 'DateTime');
        return DateTime->from_epoch(%data);
    };
}

=head2 C<< coerce_instance() : I<CODE> >>

Helper function for instances type attribute.

=cut

sub coerce_instance {
    my $class = shift;

    return sub {
        return $_[0] if not defined $_[0];
        return $_[0] if blessed($_[0]) and blessed($_[0]) eq $class;
        return $class->new($_[0]);
    };
}

=head2 C<< create_instance_type(I<$prefix>) >>

Helper function to create an "InstanceOf" type.

=cut

sub create_instance_type {
    my $type = shift;
    my $class = 'Stancer::' . $type;
    my $name = $type;

    $name =~ s/:://gsm;

    return {
        name => $name . 'Instance',
        exception => 'Stancer::Exceptions::Invalid' . $name . 'Instance',
        test => sub {
            my $instance = shift;

            return if not defined $instance;
            return if not blessed $instance;
            return $instance->isa($class);
        },
        message => sub {
            my $instance = shift;

            return 'No instance given.' if not defined $instance;
            return sprintf '"%s" is not blessed.', $instance if not blessed $instance;
            return sprintf '%s is not an instance of "%s".', $instance, $class;
        },
    };
}

=head2 C<< error_message(I<$message>) >>

=head2 C<< error_message(I<$message>, I<@args>) >>

Helper function to be used in a type definition:

    {
        ...
        message => error_message('%s is not an integer'),
        ...
    }

It will produce:

    '"something" is not an integer'
    # or with an undefined value
    'undef is not an integer'

If I<@args> is provided, it will passed to C<sprintf> internal function.

    {
        ...
        name => 'Char',
        message => error_message('Must be exactly %2$d characters, tried with %1$s.'),
        ...
    }

Will produce for a C<Char[20]> attribute:

    'Must be exactly 20 characters, tried with "something".'

=cut

sub error_message {
    my $message = shift;

    return sub {
        my $value = shift;

        if (defined $value) {
            $value = q/"/ . $value . q/"/;
        } else {
            $value = 'undef';
        }

        return sprintf $message, $value, @_;
    };
}

=head2 C<< register_types( I<$types>, I<$package> ) >>

Install the given types within the package.

This will use C< MooX::Types::MooseLike::register_types() >.

=cut

sub register_types {
    my ($defs, $package) = @_;

    for my $def (@{ $defs }) {
        if (defined $def->{exception}) {
            my $class = $def->{exception};
            my $message = $def->{message};

            $def->{message} = sub {
                if (ref $message eq 'CODE') {
                    $class->throw(message => $message->(@_));
                }

                $class->throw(message => $message);
            };
        }
    }

    return MooX::Types::MooseLike::register_types($defs, $package);
}

1;
