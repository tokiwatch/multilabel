# $Id$

package Multilabel::CMS;

use strict;
use utf8;
use MT::Blog;
use MT::Util qw( format_ts epoch2ts );
use Multilabel::Plugin;
use Multilabel::Plugin qw( multilabel_class );
use Data::Dumper;

sub view {
    my $app = shift;
    my (%opt) = @_;

    my $q    = $app->{query};
    my $tmpl = $app->load_tmpl('view.tmpl');
    my $blog_id;
    if ( $q->param('blog_id') ) {
        $blog_id = scalar $q->param('blog_id');
    }
    else {
        $blog_id = scalar 0;
    }
    my $blog  = MT::Blog->load($blog_id);
    my $class = multilabel_class($blog_id);

    if ( $q->param('id') ) {
        my $id = scalar $q->param('id');
        $tmpl->param( 'id' => $id );
        my %term;
        require Multilabel::Object;
        my $multilabel = Multilabel::Object->load($id);
        $tmpl->param( 'keyword'    => $multilabel->keyword );
        $tmpl->param( 'created_on' => $multilabel->created_on );
        my $created_by_id  = $multilabel->created_by;
        my $modified_by_id = $multilabel->modified_by;

        require MT::Author;
        my $author_id     = scalar $multilabel->created_by;
        my $create_author = MT::Author->load($author_id);
        $tmpl->param( 'created_by' => $create_author->name );

        if ( $multilabel->modified_on ) {
            $tmpl->param( 'modified_on' => $multilabel->modified_on );
        }
        if ( $multilabel->modified_by ) {
            my $modified_author = MT::Author->load( { id => $multilabel->modified_by } );
            $tmpl->param( 'modified_by' => $modified_author->name );
        }

        $tmpl->param( 'created_on_date' => format_ts( "%Y-%m-%d", $multilabel->created_on, $blog ) );
        $tmpl->param( 'created_on_time' => format_ts( "%H:%M:%S", $multilabel->created_on, $blog ) );

        my $prev = $multilabel->nextprev(
            direction => 'previous',
            terms     => { blog_id => $blog_id },
            by        => 'id'
        );
        if ($prev) {
            my $prev_multilabel_uri = $app->uri(
                mode => 'multilabel_view',
                args => {
                    'id'      => $prev->id,
                    'blog_id' => $blog_id
                }
            );

            $tmpl->param( 'prev_id'             => $prev->id );
            $tmpl->param( 'prev_multilabel_uri' => $prev_multilabel_uri );
        }

        my $next = $multilabel->nextprev(
            direction => 'next',
            terms     => { blog_id => $blog_id },
            by        => 'id'
        );
        if ($next) {
            my $next_multilabel_uri = $app->uri(
                mode => 'multilabel_view',
                args => {
                    'id'      => $next->id,
                    'blog_id' => $blog_id
                }
            );

            $tmpl->param( 'next_id'             => $next->id );
            $tmpl->param( 'next_multilabel_uri' => $next_multilabel_uri );
        }

        $tmpl->param( 'saved_changes' => scalar $q->param('saved_changes') ) if $q->param('saved_changes');
        $tmpl->param( 'saved'         => scalar $q->param('saved') )         if $q->param('saved');

        require Multilabel::ObjectData;

        my %multilabel_data_value;

        foreach my $each_class (@$class) {
            my $multilabel_data = Multilabel::ObjectData->load(
                {   multilabel_id => $id,
                    class         => $each_class
                }
            ) or undef;

            if ($multilabel_data) {
                $multilabel_data_value{$each_class} = $multilabel_data->value;
            }
            else {
                $multilabel_data_value{$each_class} = "";
            }
        }

        $tmpl->param( 'multilabel_data' => \%multilabel_data_value );
    }
    else {
        $tmpl->param( 'new_object' => 1 );

        my $author    = $app->user;
        my $author_id = scalar $author->id;
        $tmpl->param( 'created_by' => $author->name );

        my $now = epoch2ts( $blog, time() );
        $tmpl->param( 'created_on_date' => format_ts( "%Y-%m-%d", $now, $blog ) );
        $tmpl->param( 'created_on_time' => format_ts( "%H:%M:%S", $now, $blog ) );

        my %multilabel_data_value;

        foreach my $each_class (@$class) {
            $multilabel_data_value{$each_class} = "";
        }

        $tmpl->param( 'multilabel_data' => \%multilabel_data_value );

    }

    $tmpl->param( 'blog_id'             => $blog_id );
    $tmpl->param( 'screen_id'           => 'edit-multilabel' );
    $tmpl->param( '_type'               => 'multilabel' );
    $tmpl->param( 'object_label'        => 'multilabel' );
    $tmpl->param( 'object_label_plural' => 'multilabels' );
    $tmpl->param( 'object_type'         => 'multilabel' );

    return $app->build_page($tmpl);
    1;
}

sub save {
    my $app   = shift;
    my (%opt) = @_;
    my $q     = $app->{query};

    my $blog_id;

    if ( $q->param('blog_id') ) {
        $blog_id = scalar $q->param('blog_id');
    }
    else {
        $blog_id = 0;
    }
    my $blog = MT::Blog->load($blog_id);

    my $author = $app->user;

    my $now = epoch2ts( $blog, time() );
    my $ts_date = format_ts( "%Y-%m-%d", $now, $blog );
    my $ts_time = format_ts( "%H:%M:%S", $now, $blog );
    my $ts      = $ts_date . $ts_time;
    $ts =~ s/\D//g;

    my $class = multilabel_class($blog_id);

    my @defined_class;

    foreach my $e (@$class) {
        if ( $q->param($e) ) {
            push( @defined_class, $e );
        }
    }
    my @sorted_defined_class = sort(@defined_class);
    my $sorted_defined_class_string = join( ",", @sorted_defined_class );

    require Multilabel::Object;
    require Multilabel::ObjectData;

    if ( $q->param('id') ) {
        my $id      = scalar $q->param('id');
        my $co_date = $q->param('created_on_date');
        my $co_time = $q->param('created_on_time');
        my $co      = $co_date . $co_time;
        $co =~ s/\D//g;

        my $multilabel = Multilabel::Object->load($id);
        $multilabel->keyword( $q->param('keyword') ) if $q->param('keyword');
        $multilabel->class($sorted_defined_class_string);
        $multilabel->modified_on($ts);
        $multilabel->created_on($co);
        $multilabel->modified_by( $author->id );
        $multilabel->save;

        foreach my $each_class (@$class) {
            my $multilabel_data = Multilabel::ObjectData->load(
                {   multilabel_id => $id,
                    class         => $each_class
                }
            ) or undef;

            if ($multilabel_data) {
                $multilabel_data->value( $q->param($each_class) );
                $multilabel_data->save;
            }
            else {
                my $multilabel_data = Multilabel::ObjectData->new();
                $multilabel_data->multilabel_id( $multilabel->id );
                $multilabel_data->blog_id($blog_id);
                $multilabel_data->class($each_class);
                $multilabel_data->value( $q->param($each_class) );
                $multilabel_data->save;
            }
        }

        $app->add_return_arg( saved_changes => 1 );
        return $app->redirect( $app->return_uri );
    }
    else {
        my $co_date = $q->param('created_on_date');
        my $co_time = $q->param('created_on_time');
        my $co      = $co_date . $co_time;
        $co =~ s/\D//g;

        my $multilabel = Multilabel::Object->new();
        $multilabel->keyword( $q->param('keyword') ) if $q->param('keyword');
        $multilabel->class($sorted_defined_class_string);
        $multilabel->blog_id($blog_id);
        $multilabel->created_by( $author->id );
        $multilabel->modified_by( $author->id );
        $multilabel->modified_on($ts);
        $multilabel->created_on($co);
        $multilabel->save;

        foreach my $each_class (@$class) {
            my $multilabel_data = Multilabel::ObjectData->new();
            $multilabel_data->multilabel_id( $multilabel->id );
            $multilabel_data->blog_id($blog_id);
            $multilabel_data->class($each_class);
            $multilabel_data->value( $q->param($each_class) );
            $multilabel_data->save;
        }

        $app->add_return_arg( id    => $multilabel->id );
        $app->add_return_arg( saved => 1 );

        return $app->redirect( $app->return_uri );
    }

    1;
}

sub delete {
    my $app     = shift;
    my (%opt)   = @_;
    my $q       = $app->{query};
    my $blog_id = scalar $q->param('blog_id') or return;
    my $id      = scalar $q->param('id') or return;

    if ($id) {
        require Multilabel::Object;
        my $object = Multilabel::Object->load(
            {   id      => $id,
                blog_id => $blog_id
            }
        ) or die;

        require Multilabel::ObjectData;
        my @data = Multilabel::ObjectData->load( { multilabel_id => $id } ) or die;

        foreach my $e (@data) {
            $e->remove or die;
        }

        $object->remove or die;

        return $app->redirect(
            $app->uri(
                'mode' => 'list',
                args   => {
                    _type   => 'multilabel',
                    blog_id => $blog_id
                }
            )
        );
    }
    1;
}

1;
