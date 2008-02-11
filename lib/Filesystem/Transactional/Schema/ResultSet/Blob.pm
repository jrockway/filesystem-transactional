package Filesystem::Transactional::Schema::ResultSet::Blob;
use strict;
use warnings;
use Encode qw(encode);
use Digest::SHA1 qw(sha1_hex);

use base 'DBIx::Class::ResultSet';

sub read_file {
    my ($self, $id) = @_;
    return $self->find($id);
}

sub write_file {
    my ($self, $content) = @_;

    # do we really want to do this?
    my $encoded = encode('utf8', $content);

    my $id = sha1_hex($encoded);
    my $already_exists = $self->find($id);
    return $already_exists if $already_exists;

    # doesn't exist yet
    return $self->create({
        id   => $id,
        data => $encoded,
    });
}

1;
