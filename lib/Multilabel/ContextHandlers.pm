# $Id$

package Multilabel::ContextHandlers;

use strict;
use warnings;
use Multilabel::Plugin;
use Multilabel::Plugin qw( multilabel_class );

#----- Tags
sub hdlr_container {
    my ( $ctx, $args, $cond ) = @_;
    my $builder = $ctx->stash('builder');
    my $tokens  = $ctx->stash('tokens');
    my $class   = $args->{'class'} if ( $args->{'class'} );

    my $out = '';
    $ctx->{__stash}->{multilabel_class} = $class;
    $out .= $builder->build( $ctx, $tokens );
    return $out;
}

sub hdlr_tag {
    my ( $ctx, $args ) = @_;

    my $blog    = $ctx->stash('blog') or die;
    my $keyword = $args->{'keyword'}  or die;

    my $class;

    if ( $args->{'class'} ) {
        $class = $args->{'class'};
    }
    else {
        $class = $ctx->stash('multilabel_class') or die;
    }

    if ($class) {
        my $t = _transform( $keyword, $class, $blog ) or undef;
        return $t or $keyword;
    }

    1;

}

sub _transform {
    my ( $keyword, $class, $blog ) = @_;

    my $blog_id;

    if   ($blog) { $blog_id = $blog->id; }
    else         { $blog_id = 0; }

    require Multilabel::Object;
    require Multilabel::ObjectData;

    #わたってきたclassが使用可能なものかを判定する。
    my $class_list = multilabel_class($blog_id);

    my $multilabel;

    foreach my $e (@$class_list) {
        if ( $e eq $class ) {
            $multilabel = Multilabel::Object->load(
                {   keyword => $keyword,
                    blog_id => $blog_id
                }
            );
        }
    }

    my $value;

    if ($multilabel) {
        my $multilabel_id = $multilabel->id;

        my $multilabel_data = Multilabel::ObjectData->load(
            {   multilabel_id => $multilabel_id,
                class         => $class
            }
        ) or undef;

        if ($multilabel_data) {
            $value = $multilabel_data->value if ( $multilabel_data->value );
        }
    }

    if ($value) {
        return $value;
    }
    else {
        if ( $blog_id eq 0 ) {
            return $keyword;
        }
        else {
            my $parent_id = $blog->parent_id or 0;

            require MT::Blog;
            my $parent_blog = MT::Blog->load( { id => $parent_id } ) or undef;
            my $t = _transform( $keyword, $class, $parent_blog ) or undef;

            return $t or $keyword;
        }
    }
    1;
}

1;
