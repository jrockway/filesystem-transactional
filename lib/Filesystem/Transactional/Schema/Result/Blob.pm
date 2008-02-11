package Filesystem::Transactional::Schema::Result::Blob;
use strict;
use warnings;

use DBICx::DefinitionSugar;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('blobs');
__PACKAGE__->add_columns(
    id   => { VARCHAR(40), NOT_NULL },
    data => { data_type => 'BINARY', NOT_NULL },
);
__PACKAGE__->set_primary_key('id');

# note: the id depends directly on the contents of "data".  if you modify
# a row object, you're likely to fuck things up horribly.  so don't. use
# the methods in the resultset class

# at some point i'm going to change the internal representation,
# so stick to "read" for getting the data out

sub read {
    my $self = shift;
    return $self->data;
}

sub write {
    die "Do not write.";
}

1;
