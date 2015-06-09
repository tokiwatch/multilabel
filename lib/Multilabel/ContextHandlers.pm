# $Id$

package Multilabel::ContextHandlers;

use strict;
use warnings;

#----- Tags
sub hdlr_container {
    my ($ctx, $args, $cond) = @_;
    my $builder = $ctx->stash('builder');
    my $tokens = $ctx->stash('tokens');
    my %term;
    $term{id} = $args->{'id'} if ($args->{'id'});

    if ($args->{'blog_id'}) {
        $term{blog_id} = $args->{'blog_id'};
    }
    else{
        $term{blog_id} = $ctx->stash('blog_id');
    }

    $term{key} = $args->{'key'} if ($args->{'key'});

    my %params;
    $params{sort} = 'id';
    $params{direction}= "aescend";
    if ($args->{'last'}){
        $params{limit} = $args->{'last'};
    }
    else {
        $params{limit} = "10";
    }

    require Multilabel::Object;
    my @stickies = Multilabel::Object->load( \%term,\%params);
    my $out = '';
    foreach my $q (@stickies){
        local $ctx->{__stash}->{stickies}=$q;
        $out .= $builder->build($ctx, $tokens);
    }
    return $out;
}

sub hdlr_tag_id {
    my ($ctx, $args) = @_;
    my $row = $ctx->stash('stickies');
    return $row->id;
}

sub hdlr_tag_blog_id {
    my ($ctx, $args) = @_;
    my $row = $ctx->stash('stickies');
    return $row->blog_id;
}

sub hdlr_tag_key {
    my ($ctx, $args) = @_;
    my $row = $ctx->stash('stickies');
    return $row->key;
}

sub hdlr_tag_value {
    my ($ctx, $args) = @_;
    my $row;
    if ($ctx->stash('stickies')) {
        $row = $ctx->stash('stickies');
    }
    else {
        if ($args->{'key'}) {
            my %term;
            $term{key} = $args->{'key'};
            if ($args->{'blog_id'}) {
                $term{blog_id} = scalar $args->{'blog_id'};
            }
            else {
                $term{blog_id} = scalar $ctx->stash('blog_id');
            }
            require Multilabel::Object;
            $row = Multilabel::Object->load(\%term);
            unless ($row){
                if ($args->{'parent'}) {
                    if (scalar $args->{'parent'}) {
                        require MT::Blog;
                        my $blog = MT::Blog->load({ id => scalar $ctx->stash('blog_id') });
                        $term{blog_id} = scalar $blog->parent_id;
                        $row = Multilabel::Object->load(\%term);
                    }
                }
            }
            unless ($row) {
                $term{blog_id} = 0;
                $row = Multilabel::Object->load(\%term);
            }
        }
    }
    if ($row) {
        return $row->value;
    }
    else {
        return;
    }
    1;
}

sub hdlr_tag_created_date {
    my ($ctx, $args) = @_;
    my $format;
    if ($args->{'format'}){
        $format = $args->{'format'};
    }
    else {
        $format = "%b. %e, %Y";
    }
    my $row = $ctx->stash('stickies');
    use MT::Util qw( format_ts );
    return format_ts($format,$row->created_on);
}

sub hdlr_tag_modified_date {
    my ($ctx, $args) = @_;
    my $format;
    if ($args->{'format'}){
        $format = $args->{'format'};
    }
    else {
        $format = "%b. %e, %Y";
    }
    my $row = $ctx->stash('stickies');
    use MT::Util qw( format_ts );
    return format_ts($format,$row->modified_on);
}

sub hdlr_tag_author_id {
    my ($ctx, $args) = @_;
    my $row = $ctx->stash('stickies');
    return $row->created_by;
}

1;
