#!perl

use DBIx::Class::Schema;
use DBIx::Class::DataImporter;
use Test::More tests => 3;

my $sch1 = bless {}, 'DBIx::Class::Schema';
my $sch2 = bless {}, 'DBIx::Class::Schema';

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
    src_schema => $sch1,
    dest_schema => $sch2,
    import_maps => [{}],
}), 'object created with valid parameters');
