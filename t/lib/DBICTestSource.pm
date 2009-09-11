package # hide from PAUSE 
    DBICTestSource;

use strict;
use warnings;
use parent 'DBICTest';
use DBICTestSource::Schema;

=head1 NAME

DBICTestSource - Library to be used by DBIx::Class::DataImporter test scripts.

=head1 SYNOPSIS

  use lib qw(t/lib);
  use DBICTestSource;
  use Test::More;
  
  my $schema = DBICTestSource->init_schema();

=head1 DESCRIPTION

This module provides the basic utilities to write tests against 
DBIx::Class.

=head1 METHODS

=head2 init_schema

  my $schema = DBICTestSource->init_schema(
    no_deploy=>1,
    no_populate=>1,
    storage_type=>'::DBI::Replicated',
    storage_type_args=>{
    	balancer_type=>'DBIx::Class::Storage::DBI::Replicated::Balancer::Random'
    },
  );

This method removes the test SQLite databases in t/var/*.db 
and then creates new, empty databases.

This method will call deploy_schema() by default, unless the 
no_deploy flag is set.

Also, by default, this method will call populate_schema() by 
default, unless the no_deploy or no_populate flags are set.

=cut

sub populate_schema {
    my $self = shift;
    my $schema = shift;

    $schema->populate('Cust', [
        [ qw/id firstname lastname/ ],
        [ 1, 'Joe', 'Blow' ],
        [ 2, 'John', 'Smith' ],
        [ 3, 'Ralph', 'Jones' ],
        ]);
}

1;
