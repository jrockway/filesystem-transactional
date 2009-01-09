package Filesystem::Transactional::Model;
use Moose;

use Filesystem::Transactional::Schema;

has 'schema' => (
    is       => 'ro',
    isa      => 'Filesystem::Transactional::Schema',
    requried => 1,
);

sub _find_path {
    my ($self, $path) = @_;
    Filesystem::Transactional::Schema::ResultSet::Tree::_normalize_filename($path);
    return $self->schema->resultset('Tree')->find_by_path($path);
}

# these functions return truee on success, die otherwise. we will need
# to wrap these for FUSE use (it expects 0 == success, 1 == error 1,
# etc.)

sub open {
    return 1;
}

sub readdir {
    my ($self, $path) = @_;
    my @files = map { $_->filename } $self->_find_path($path)->children;
    return @files;
}

sub read {
    my ($self, $path, $size, $offset) = @_;
    my $content = $self->_find_path($path)->content->read;
    return substr $content, $offset, $size;
}

sub write {
    my ($self, $path, $buf, $offset) = @_;
    my $content = substr $buf, $offset;
    $self->schema->resultset('Tree')->write_file($path, $content);
    return 1;
}

1;

__END__

=head1 SYNOPSIS

This file makes the Filesystem::Transactional::Schema look like a filesystem
