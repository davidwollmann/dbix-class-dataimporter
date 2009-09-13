#!perl

use DBIx::Class::Schema;
use DBIx::Class::DataImporter;
use Test::More tests => 4;

eval {
    DBIx::Class::DataImporter->new();
};
ok($@, 'constructor raises exception without parameters');

eval {
    DBIx::Class::DataImporter->new({
        src_schema => undef,
        dest_schema => undef,
        import_maps => [{}],
    });
};
ok($@, 'constructor raises exception with invalid parameters');

ok(my $importer = DBIx::Class::DataImporter->new({
    src_schema => bless({}, 'DBIx::Class::Schema'),
    dest_schema => bless({}, 'DBIx::Class::Schema'),
    import_maps => [
        {
            from_source => 'foo',
            to_source => 'bar',
            map => [
                'field1' => 'field1',
                'field2' => [sub { 'does nothing' },'field2'],
            ]
        },
    ],
}), 'object created with valid parameters');

ok(my $importer = DBIx::Class::DataImporter->new({
    src_schema => bless({}, 'DBIx::Class::Schema'),
    dest_schema => bless({}, 'DBIx::Class::Schema'),
    import_maps => [
        {
            from_source => 'foo',
            from_source_rs_method => { search => { id => { '>' => 100 } } },
            to_source => 'bar',
            map => [
                'field1' => 'field1',
                'field2' => [sub { 'does nothing' },'field2'],
            ]
        },
    ],
}), 'object created with valid parameters and optional from_source_rs_method parameter');

