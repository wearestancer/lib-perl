package Stancer::Core::Types::String;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Internal strings types
# VERSION

our @EXPORT_OK = ();
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

use Stancer::Core::Types::Helper qw(error_message);

use Stancer::Exceptions::InvalidDescription;
use Stancer::Exceptions::InvalidEmail;
use Stancer::Exceptions::InvalidExternalId;
use Stancer::Exceptions::InvalidMobile;
use Stancer::Exceptions::InvalidName;
use Stancer::Exceptions::InvalidOrderId;
use Stancer::Exceptions::InvalidUniqueId;

use namespace::clean;

use Exporter qw(import);

sub _create_type {
    my ($name, $params) = @_;

    return {
        name => $name,
        exception => $params->{exception},
        test => sub {
            my ($value, $min, $max) = @_;

            $min = $params->{min} if defined $params->{min};
            $max = $params->{max} if defined $params->{max};

            return 0 if not defined $value;

            $max = 0 if not defined $max;
            $min = 0 if not defined $min;

            if ($min > $max) {
                ($min, $max) = ($max, $min);
            }

            return length($value) >= $min && length($value) <= $max;
        },
        message => sub {
            my ($value, $min, $max) = @_;

            $min = $params->{min} if defined $params->{min};
            $max = $params->{max} if defined $params->{max};

            if (defined $value) {
                $value = q/"/ . $value . q/"/;
            } else {
                $value = 'undef';
            }

            if (not defined $max) {
                return 'Must be at maximum ' . $min . ' characters, tried with ' . $value . q/./;
            }

            if (not defined $min) {
                return 'Must be at maximum ' . $max . ' characters, tried with ' . $value . q/./;
            }

            if ($min > $max) {
                ($min, $max) = ($max, $min);
            }

            return 'Must be an string between ' . $min . ' and ' . $max . ' characters, tried with ' . $value . q/./;
        },
    };
}

my @defs = ();

push @defs, {
    name => 'Char',
    test => sub {
        my ($value, $param) = @_;

        if (not defined $value) {
            return 0;
        }

        length($value) == $param;
    },
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    message => error_message('Must be exactly %2$d characters, tried with %1$s.'),
    ## use critic
};

push @defs, _create_type('Varchar');

push @defs, _create_type('Description', { min => 3, max => 64, exception => 'Stancer::Exceptions::InvalidDescription' });
push @defs, _create_type('Email', { min => 5, max => 64, exception => 'Stancer::Exceptions::InvalidEmail' });
push @defs, _create_type('ExternalId', { max => 36, exception => 'Stancer::Exceptions::InvalidExternalId' });
push @defs, _create_type('Mobile', { min => 8, max => 16, exception => 'Stancer::Exceptions::InvalidMobile' });
push @defs, _create_type('Name', { min => 4, max => 64, exception => 'Stancer::Exceptions::InvalidName' });
push @defs, _create_type('OrderId', { max => 36, exception => 'Stancer::Exceptions::InvalidOrderId' });
push @defs, _create_type('UniqueId', { max => 36, exception => 'Stancer::Exceptions::InvalidUniqueId' });

Stancer::Core::Types::Helper::register_types(\@defs, __PACKAGE__);

1;
