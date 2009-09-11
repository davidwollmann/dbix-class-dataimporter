package DBICTestDestination::Schema::Result::Customer;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('customer');
__PACKAGE__->add_columns(
    'id',
    {
        data_type => 'INT',
        default_value => undef,
        is_auto_increment => 1,
        is_nullable => 0,
        size => 10,
    },
    'firstname',
    {
        data_type => 'CHAR',
        default_value => undef,
        is_nullable => 0,
        size => 32,
    },
    'lastname',
    {
        data_type => 'CHAR',
        default_value => undef,
        is_nullable => 0,
        size => 32,
    },
);

1;
