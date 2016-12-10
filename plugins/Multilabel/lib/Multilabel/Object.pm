# $Id$

package Multilabel::Object;
use warnings;
use strict;
use Carp;
use MT::Object;
use base qw( MT::Object );

__PACKAGE__->install_properties(
    {
        column_defs => {
            'id'      => 'integer not null auto_increment',
            'keyword' => 'text not null',
            'blog_id' => 'integer not null',
            'class'   => 'string(255)',
            'title'   => 'text not null',
        },
        indexes => {
            'id'      => 1,
            'blog_id' => 1,
        },
        datasource  => 'multilabel',
        child_of    => 'MT::Blog',
        audit       => 1,
        primary_key => 'id',
    }
);

1;

__END__
