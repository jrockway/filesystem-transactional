use strict;
use warnings;
use Test::More tests => 23;

use DBICx::TestDatabase;

my $schema = DBICx::TestDatabase->new('Filesystem::Transactional::Schema');

my $rs = $schema->resultset('Tree');
$rs->mkdir('/foo/bar/baz');

{
    no warnings 'redefine';
    local *is = sub { 
        Test::More::is($_[0], $_[1], 
                       'ensure that row has right properties')
      };
    is $rs->find(1)->filename, 'foo';
    is $rs->find(2)->filename, 'bar';
    is $rs->find(3)->filename, 'baz';
    is $rs->find(1)->parent_id, '0';
    is $rs->find(2)->parent_id, '1';
    is $rs->find(3)->parent_id, '2';
}

$rs->mkdir('/foo/bar/quux');
is $rs->find(4)->filename, 'quux';
is $rs->find(4)->parent_id, '2';

is $rs->count, 4;
$rs->mkdir('/foo/bar/baz');
is $rs->count, 4, 'making an existing dir is NOP';

# try making a file now
my $file = $rs->write_file('/etc/passwd', 'super:s:e:c:r:e:t');
is $file->content->read, 'super:s:e:c:r:e:t';
is $file->path, '/etc/passwd';
is $rs->count, 6, 'added /etc; /etc/passwd';

# update the file
$file = $rs->write_file('/etc/passwd', 'updated content');
is $file->content->read, 'updated content';
is $file->path, '/etc/passwd';
is $rs->count, 6, 'still only 6 files';

# make a file at the root
$file = $rs->write_file('/root', 'this is /root');
is $file->content->read, 'this is /root';
is $file->path, '/root';
is $rs->count, 7, 'added /root';

# make a file under existing dir
$file = $rs->write_file('/foo/bar/SOME NEW FILE', 'SOME NEW FILE');
is $file->content->read, 'SOME NEW FILE';
is $file->path, '/foo/bar/SOME NEW FILE';
is $rs->count, 8, 'added SOME NEW FILE';

# XXX: probably possible to mkdir '/foo/bar' then write to it.  ick.

# test deletion
my $foo = $rs->find_by_path('/foo');
$foo->delete; # kills /foo /foo/bar /foo/bar/quux 
              #       /foo/bar/baz /foo/bar/SOME NEW FILE

is $rs->count, '3', 'killed lots of files';
