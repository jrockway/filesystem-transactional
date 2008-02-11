use inc::Module::Install;

name 'Filesystem-Transactional';
all_from 'lib/Filesystem/Transactional.pm';

requires 'DBIx::Class';
requires 'DBIx::Class::Tree::AdjacencyList';
requires 'Digest::SHA';
build_requires 'DBICx::TestDatabase';
build_requires 'Test::More';
build_requires 'ok';

tests "t/*.t t/schema/*.t";

WriteAll();
