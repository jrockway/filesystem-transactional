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

sub mkdir {
    my ($self, $new) = @_;
    my $rs = $self->result_source->schema->resultset('Tree');
    _normalize_path($new);
    my @tree = split m{/}, $new;
    
    return $self->result_source->schema->txn_do(sub {
        my $current = $rs->find_or_create({
            parent_id => 0,
            filename  => shift @tree,
        });
        
        foreach my $node (@tree){
            # search
            my $new_dir = $current->find_or_create_related( children => {
                'filename' => $node,
            });
            
            $current = $new_dir;
        }
        return $current;
    });
}

sub write_file {
    my ($self, $path, $content) = @_;
    _normalize_path($path);
    my @dirs = split m{/}, $path;
    my $filename = pop @dirs;
    
    my $schema = $self->result_source->schema;
    return $schema->txn_do(sub {
        my $file;
        my $content = $schema->resultset('Blob')->write_file($content);
        
        if(@dirs){
            my $dir = $self->mkdir(join '/', @dirs);
            $file = $dir->find_or_create_related(children => {
                filename => $filename,
            });
        }
        else {
            $file = $schema->resultset('Tree')->create({
                filename => $filename,
            });
        }
        $file->content($content);
        $file->insert_or_update;
        return $file;
    });
}

1;
