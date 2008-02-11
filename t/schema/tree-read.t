use strict;
use warnings;
use Test::More tests => 13;
use feature ':5.10';

use DBICx::TestDatabase;

my $schema = DBICx::TestDatabase->new('Filesystem::Transactional::Schema');

my $rs = $schema->resultset('Tree');
isa_ok $rs, 'Filesystem::Transactional::Schema::ResultSet::Tree', '$rs';

{
    my $mk_file = sub { 
        state $blob_rs = $schema->resultset('Blob');
        $blob_rs->write_file(shift);
    };
    
    # foo, bar, baz/, baz/quux
    $rs->create({ 
        parent_id => 0,
        filename  => $_,
        content   => $mk_file->("This is $_"),
    }) for qw/foo bar/;
    my $baz = $rs->create({
        parent_id => 0,
        filename  => 'baz',
        content   => undef,
    });
    $baz->create_related( children => {
        filename => 'quux',
        content  => $mk_file->("This is quux"),
    });
}

is $rs->count, 4, '4 entries';
my $root = $rs->ls_by_parent_id(0);
is $root->count, 3, '3 files in /';

is $rs->ls_by_parent_id(2), 0, 'no files under 2';
is $rs->ls_by_parent_id(3), 1, '1 file under 3';

is $rs->find(2)->filename, 'bar';
is $rs->find(2)->get_column('content'), '27d7b0b544c4f31c9051db01c1554b0a544a54e6';
is $rs->find(2)->content->read, 'This is bar';
is $rs->find(2)->path, '/bar', 'path to bar is /bar';
is $rs->find(3)->path, '/baz', '3 = /baz';
is $rs->find(4)->path, '/baz/quux', 'path to quux is /baz/quux';

my $quux = $rs->find_by_path('baz/quux');
is $quux->content->read, 'This is quux';

ok !$rs->find_by_path('/etc/passwd/you/fail'), "search for nothing";
