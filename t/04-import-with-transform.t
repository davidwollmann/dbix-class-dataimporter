#!perl

use DBIx::Class::DataImporter;
use Test::More 'no_plan';
use lib qw(t/lib);
use DBICTestSource;
use DBICTestDestination;

# set up and populate schemata
ok(my $source = DBICTestSource->init_schema( sqlite_use_file => 1 ), 'got schema');
ok(my $destination = DBICTestDestination->init_schema( sqlite_use_file => 1 ), 'got schema');

sub upcase { uc $_[0] }

my $imp = DBIx::Class::DataImporter->new(
    src_schema => $source,
    dest_schema => $destination,
    import_maps => [
        {
            from_source => 'Cust',
            to_source => 'Customer',
            map => [
                id => 'id',
                firstname => 'firstname',
                lastname => [ \&upcase, 'lastname' ],
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
ok($row->lastname eq 'BLOW', 'row id 1 firstname eq "BLOW"');
$row = $rs->find({id => 2});
ok($row->firstname eq 'John', 'row id 2 firstname eq "John"');
ok($row->lastname eq 'SMITH', 'row id 2 firstname eq "SMITH"');
$row = $rs->find({id => 3});
ok($row->firstname eq 'Ralph', 'row id 3 firstname eq "Ralph"');
ok($row->lastname eq 'JONES', 'row id 3 firstname eq "JONES"');

