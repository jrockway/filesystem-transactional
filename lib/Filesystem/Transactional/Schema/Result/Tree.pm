package Filesystem::Transactional::Schema::Result::Tree;
use strict;
use warnings;

use DBICx::DefinitionSugar;
use base 'DBIx::Class';

# TODO metadata (links, xattr, mtime, etc.)

__PACKAGE__->load_components(qw/Core Tree::AdjacencyList/);
__PACKAGE__->table('tree');
__PACKAGE__->add_columns(
    id        => { INTEGER_PRIMARY_KEY() },
    parent_id => { INTEGER, NULL }, # root node is id 0
    filename  => { TEXT, NOT_NULL },
    content   => { VARCHAR(50), NULL },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->parent_column('parent_id');

# only one of each filename per directory
__PACKAGE__->add_unique_constraint( 
    directory_file => [qw/parent_id filename/]
);

__PACKAGE__->belongs_to(
    content => 'Filesystem::Transactional::Schema::Result::Blob',
);

sub path {
    my $self = shift;
    return '/'.$self->filename if !$self->parent_id;
    return $self->parent->path . '/'. $self->filename;
}

1;
