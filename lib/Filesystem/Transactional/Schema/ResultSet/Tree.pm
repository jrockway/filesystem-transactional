package Filesystem::Transactional::Schema::ResultSet::Tree;
use strict;
use warnings;
use feature ':5.10';

use base 'DBIx::Class::ResultSet';

sub ls_by_parent_id {
    my ($self, $parent_id) = @_;
    return $self->search({ parent_id => $parent_id });
}

sub find_by_path {
    my ($self, $path) = @_;
    _normalize_path($path);
    my @path = split m{/}, $path;
    
    my $top = shift @path;
    my $rs = $self->result_source->schema->resultset('Tree')
      ->search({ 'me.parent_id' => 0,  'me.filename' => $top });

    # DBIC should do this for me.
    my $i = 1;
    for my $part (@path){
        my $col = $i == 1 ? 'children.filename' : "children_$i.filename";
        $rs = $rs->search_related(children => { $col => $part });
        $i++;
    }
    
    return $rs->first; # guaranteed to be 0 or 1
}

sub _normalize_path {
    $_[0] =~ s{/+}{/}g;
    $_[0] =~ s{^/}{}g;
}

1;
