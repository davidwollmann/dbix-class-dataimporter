package DBIx::Class::DataImporter::Types;

use warnings;
use strict;

use MooseX::Types -declare => [qw(
    ImportMap
    ImportMapList
    MethodCall
)];
use MooseX::Types::Moose qw( Str ArrayRef HashRef CodeRef );
use MooseX::Types::Structured qw( Tuple Dict Optional );

subtype MethodCall,
    as Tuple[CodeRef,Str];

subtype ImportMap,
    as Dict[
        from_source => Str,
        from_source_rs_method => Optional[HashRef],
        to_source => Str,
        map => ArrayRef[Str|MethodCall],
    ];

subtype ImportMapList,
    as ArrayRef[ImportMap];

1;
