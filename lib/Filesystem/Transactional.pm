package Filesystem::Transactional;
use strict;
use warnings;

1;
__END__

=head1 NAME

Filesystem::Transactional - a FUSE filesystem that suports RDMBS transaction
semantics.

=head1 SYNOPSIS

  # XXX: mount the fileystem somehow

  $ cd txnfs
  $ touch .txn/begin
  $ touch "foo" "bar"
  $ ls
  foo    bar
  $ touch .txn/rollback
  $ ls
  # no files!

=head1 DESCRIPTION

  $ rm -rf /
  # OH FUCK
  $ touch /.txn/rollback
  # DISASTER AVERTED

