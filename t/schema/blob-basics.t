use strict;
use warnings;
use Test::More tests => 7;

use DBICx::TestDatabase;

my $schema = DBICx::TestDatabase->new('Filesystem::Transactional::Schema');

my $rs = $schema->resultset('Blob');
isa_ok $rs, 'Filesystem::Transactional::Schema::ResultSet::Blob', '$rs';

my $hello = $rs->write_file("Hello, world!");
ok $hello, 'wrote $hello ok';
is $rs->count, 1, '1 file';

my $id = $hello->id;
is $id, '943a702d06f34599aee1f8da8ef9f7296031d699', 'assigned correct id';

my $hello2 = $rs->read_file($id);
is $hello2->read, "Hello, world!", 'correct data after lookup';

my $hello3 = $rs->write_file("Hello, world!");
is $hello3->id, $id, 'same id as hello';

is $rs->count, 1, 'still only 1 file';
