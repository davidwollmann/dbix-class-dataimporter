#!perl

# ok, this is really a meta-test, but it's cheap insurance

use DBIx::Class::DataImporter;
use Test::More tests => 2;
use lib qw(t/lib);
use DBICTestSource;
use DBICTestDestination;

# set up and populate schemata
ok(my $source = DBICTestSource->init_schema( sqlite_use_file => 1 ), 'got schema');
ok(my $destination = DBICTestDestination->init_schema( sqlite_use_file => 1 ), 'got schema');

