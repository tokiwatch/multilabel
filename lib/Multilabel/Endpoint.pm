# $Id$

package Multilabel::Endpoint;

use strict;
use warnings;
use MT::DataAPI::Endpoint::Common;
use MT::Util;

sub list {
    my ( $app, $endpoint ) = @_;

    my %terms;

    if (defined $app->param('blog_id')){
        $terms{blog_id} = scalar $app->param('blog_id');
    }
    else {
        return '';
    }

    require Multilabel::Object;
    my @objects = Multilabel::Object->load(\%terms) or return '';

    my @results;
    foreach my $object (@objects){
        my $values = $object->{'column_values'};
        my %contents;
        while (my ($key, $value) = each($values)){
            $contents{$key} = $value;
        }
        push(@results, \%contents);
    }

    return { items => \@results, results => scalar(@results)};

}

sub get {
    my ( $app, $endpoint ) = @_;

    my %terms;
    if ($app->param('id')){
        $terms{id} = scalar $app->param('id');
    }
    else {
        return '';
    }

    if ($app->param('blog_id')){
        $terms{blog_id} = scalar $app->param('blog_id');
    }
    unless (defined $terms{blog_id}){
        $terms{blog_id} = 0;
    }

    require Multilabel::Object;
    my $object = Multilabel::Object->load(\%terms) or return '';

    my $values = $object->{'column_values'};
    my %contents;
    while (my ($key, $value) = each($values)){
        $contents{$key} = $value;
    }
    return \%contents;
}

sub create {
    my ( $app, $endpoint ) = @_;

    my ($blog) = context_objects(@_) or return;

    my $author = $app->user;

    require Multilabel::Object;
    my $multilabel = Multilabel::Object->new();
    $multilabel->blog_id($blog->id);
    $multilabel->created_by($author->id);

    if (defined $app->param('key')) {
        $multilabel->key($app->param('key'));
    }
    else {
        return;
    }

    if (defined $app->param('value')){
        $multilabel->value($app->param('value'));
    }
    else {
        return;
    }

    $multilabel->save or return;

    my $values = $multilabel->{'column_values'};
    my %contents;
    while (my ($key, $value) = each($values)){
        $contents{$key} = $value;
    }
    return \%contents;
}

sub update {
    my ( $app, $endpoint ) = @_;

    my ($blog) = context_objects(@_);

    my $author = $app->user;

    return '' unless defined $app->param('id');

    my $new_multilabel_data = MT::Util::from_json($app->param('multilabel'));

    my %terms;
    $terms{id} = $app->param('id');
    $terms{blog_id} = $app->param('blog_id');

    require Multilabel::Object;
    my $multilabel = Multilabel::Object->load(\%terms);
    $multilabel->modified_by($author->id);

    if (defined $new_multilabel_data->{'key'}) {
        $multilabel->key($new_multilabel_data->{'key'});
    }
    else {
        return;
    }

    if (defined $new_multilabel_data->{'value'}) {
        $multilabel->value($new_multilabel_data->{'value'});
    }
    else {
        return;
    }

    $multilabel->save or return;

    my $values = $multilabel->{'column_values'};
    my %contents;
    while (my ($key, $value) = each($values)){
        $contents{$key} = $value;
    }
    return \%contents;
}

sub delete {
    my ( $app, $endpoint ) = @_;
    # #
    # # my ($blog) = context_objects(@_)
    # #     or return;
    #
    my $author = $app->user;

    my %terms;
    $terms{id} = $app->param('id');
    $terms{blog_id} = $app->param('blog_id');

    require Multilabel::Object;
    my $multilabel = Multilabel::Object->load(\%terms) or return;
    $multilabel->remove or return;

    my $values = $multilabel->{'column_values'};
    my %contents;
    while (my ($key, $value) = each($values)){
        $contents{$key} = $value;
    }
    return \%contents;
}

1;
