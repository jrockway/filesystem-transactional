use inc::Module::Install;

name 'Filesystem-Transactional';
all_from 'lib/Filesystem/Transactional.pm';

build_requires 'Test::More';
build_requires 'ok';

WriteAll();
