# $Id$

package Multilabel::ObjectData;
use warnings;
use strict;
use Carp;
use MT::Object;
use base qw( MT::Object );

__PACKAGE__->install_properties(
    {
        column_defs => {
            'id'            => 'integer not null auto_increment',
            'blog_id'       => 'integer not null',
            'multilabel_id' => 'integer not null',
            'class'         => 'string(255) not null',
            'value'         => 'text',
        },
        indexes => {
            'id'            => 1,
            'blog_id'       => 1,
            'multilabel_id' => 1,
        },
        datasource => 'multilabel_data',
        child_of   => 'MT::Blog',
        #audit => 1,
        primary_key => 'id',
    }
);

1;

__END__
