package DBIx::Class::DataImporter::Types;

use warnings;
use strict;

use MooseX::Types
    -declare => [qw(
        ImportMapList
    )];

use MooseX::Types::Moose qw(
    Str
    ArrayRef
    HashRef
);

subtype ImportMapList,
    as ArrayRef[HashRef];
