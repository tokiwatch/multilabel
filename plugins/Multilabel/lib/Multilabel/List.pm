# $Id$

package Multilabel::List;

use strict;
use warnings;

sub html_link {
    my $prop = shift;
    my ( $obj, $app, $opts ) = @_;
    return $app->uri(
        mode => 'multilabel_view',
        args => {
            id      => $obj->id,
            blog_id => $obj->blog_id
        },
    );
}

sub defined_class_list {
    my $prop = shift;
    my ( $obj, $app, $opts ) = @_;
    return $obj->id;
}

sub delete {
    my $app = shift;
    $app->validate_magic or return;

    my $q   = $app->param;
    my @ids = $app->param('id');

    require Multilabel::Object;
    require Multilabel::ObjectData;
    foreach my $a (@ids) {
        my $object = Multilabel::Object->load( { id => $a } ) or die;
        my @data = Multilabel::ObjectData->load( { multilabel_id => $a } ) or die;
        foreach my $e (@data) {
            $e->remove or die;
        }
        $object->remove or die;
    }
    $app->add_return_arg( promoted => 1 );
    $app->call_return;

}

1;
