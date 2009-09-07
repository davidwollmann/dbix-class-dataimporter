#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'DBIx::Class::DataImporter' ) or BAIL_OUT($@);
}

diag( "Testing DBIx::Class::DataImporter $DBIx::Class::DataImporter::VERSION, Perl $], $^X" );
