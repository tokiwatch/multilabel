# $Id$

package Multilabel::Plugin;

use strict;
use warnings;
use Data::Dumper;
use Exporter 'import';
our @EXPORT_OK = qw( multilabel_class );

sub plugin {
    return MT->component('Multilabel');
}

sub multilabel_class {
    my $plugin = plugin();
    my ($blog_id) = @_;

    my $plugin_params = $plugin->get_config_hash( 'blog:' . $blog_id ) or die;

    my @array = split( /, */, $plugin_params->{multilabel_class} );

    return \@array;
}

1;
