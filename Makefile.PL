use inc::Module::Install 0.79;

perl_version '5.010001';
name     'DBIx-Class-DataImporter';
all_from 'lib/DBIx/Class/DataImporter.pm';

requires 'DBIx::Class' => 0.08102;
requires 'Moose' => '0.86';
requires 'MooseX::Types' => '0.16';

build_requires 'Test::More'       => 0.7;

tests_recursive();

auto_install;

WriteAll;
