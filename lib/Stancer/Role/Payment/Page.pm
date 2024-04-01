package Stancer::Role::Payment::Page;

use 5.020;
use strict;
use warnings;

# ABSTRACT: Payment page relative role
# VERSION

use Stancer::Core::Types qw(Maybe Url);

use Stancer::Config;
use Stancer::Exceptions::MissingReturnUrl;
use Stancer::Exceptions::MissingPaymentId;
use Stancer::Exceptions::MissingApiKey;
use Try::Tiny;

use Moo::Role;

requires qw(_add_modified _attribute_builder id);

use namespace::clean;

=attr C<return_url>

Read/Write string.

URL used to return to your store when using the payment page.

=cut

has return_url => (
    is => 'rw',
    isa => Maybe[Url],
    builder => sub { $_[0]->_attribute_builder('return_url') },
    lazy => 1,
    predicate => 1,
    trigger => sub { $_[0]->_add_modified('return_url') },
);

=method C<< $payment->payment_page_url() >>

=method C<< $payment->payment_page_url( I<%params> ) >>

=method C<< $payment->payment_page_url( I<\%params> ) >>

External URL for Stancer payment page.

Maybe used as an iframe or a redirection page if you needed it.

C<%terms> must be an hash or a reference to an hash (C<\%terms>) with at least one of the following key :

=over

=item C<lang>

To force the language of the page.

The page uses browser language as default language.
If no language available matches the asked one, the page will be shown in english.

=back

=cut

sub payment_page_url {
    my ($this, @args) = @_;
    my $data;

    if (scalar @args == 1) {
        $data = $args[0];
    } else {
        $data = {@args};
    }

    my $config = Stancer::Config->init();

    if (not defined $this->return_url) {
        my $message = 'You must provide a return URL before going to the payment page.';

        Stancer::Exceptions::MissingReturnUrl->throw(message => $message);
    }

    if (not defined $this->id) {
        my $message = 'A payment ID is mandatory to obtain a payment page URL. Maybe you forgot to send the payment.';

        Stancer::Exceptions::MissingPaymentId->throw(message => $message);
    }

    my $pattern = 'https://%s/%s/%s';
    my $host = $config->host;
    my $url;

    $host =~ s/api/payment/sm;

    try {
        $url = sprintf $pattern, $host, $config->public_key, $this->id;
    }
    catch {
        my $message = 'A public API key is needed to obtain a payment page URL.';

        Stancer::Exceptions::MissingApiKey->throw(message => $message);
    };

    my @params = ();

    push @params, 'lang=' . $data->{'lang'} if defined $data->{'lang'};

    if (scalar @params) {
        $url .= q/?/ . join q/&/, @params;
    }

    return $url;
}

1;
