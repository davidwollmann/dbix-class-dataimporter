#!perl

use DBIx::Class::DataImporter;
use Test::More tests => 10;
use lib qw(t/lib);
use DBICTestSource;
use DBICTestDestination;

# set up and populate schemata
ok(my $source = DBICTestSource->init_schema( sqlite_use_file => 1 ), 'got schema');
ok(my $destination = DBICTestDestination->init_schema( sqlite_use_file => 1 ), 'got schema');

my $imp = DBIx::Class::DataImporter->new(
    src_schema => $source,
    dest_schema => $destination,
    import_maps => [
        {
            from_source => 'Cust',
            to_source => 'Customer',
            map => [
                'id' => 'id',
                'firstname' => 'firstname',
                'lastname' => 'lastname',
            ]
        },
    ],
);

isa_ok($imp, 'DBIx::Class::DataImporter');

$imp->run_import();

my $rs = $destination
    ->resultset('Customer')
    ->search(undef, { order_by => { -asc => [ 'id' ] } });
is($rs->count, 3, 'fetch three rows');
my $row;
$row = $rs->find({id => 1});
ok($row->firstname eq 'Joe', 'row id 1 firstname eq "Joe"');
ok($row->lastname eq 'Blow', 'row id 1 firstname eq "Blow"');
$row = $rs->find({id => 2});
ok($row->firstname eq 'John', 'row id 2 firstname eq "John"');
ok($row->lastname eq 'Smith', 'row id 2 firstname eq "Smith"');
$row = $rs->find({id => 3});
ok($row->firstname eq 'Ralph', 'row id 3 firstname eq "Ralph"');
ok($row->lastname eq 'Jones', 'row id 3 firstname eq "Jones"');

