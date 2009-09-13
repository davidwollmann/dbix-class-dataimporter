package DBIx::Class::DataImporter;
use Moose;
use DBIx::Class::Exception;
use DBIx::Class::DataImporter::Types qw(
    ImportMapList
);

our $VERSION = '0.01';

=head1 NAME

DBIx::Class::DataImporter

=head1 SYNOPSIS

 package My::Importer;
 use Moose;
 extends 'DBIx::Class::DataImporter';

 sub lookup_state_id {
    my $state = shift;
    my $id = ...;
    return $id;
 }

 sub find_or_new_zip_id {
     my $zip = shift;
     my $id = ...; # find existing email row or insert new email row, return id
     return $id;
 }

 sub find_or_new_email_id {
     my $email = shift;
     my $id = ...; # find existing email row or insert new email row, return id
     return $id;
 }

 # In your program

 use My::Importer;

 my $imp = My::Importer->new(
    src_schema => $oldschema,
    dest_schema => $newschema,
    import_maps => [
        {
            from_source => 'cust',
            from_source_rs_method => [ search => { id => { '>' => 100 } } ],
            to_source => 'Customer',
            map => [
                name => 'name',
                address1 => 'street1',
                city => 'city',
                state => [ \&lookup_state_id, 'state' ],
                zip => [ \&find_or_new_zip_id, 'zipcode' ],
                email => [ \&find_or_new_email_id, 'emailaddr' ],
            ]
        },
    ]
 );

 $imp->run_import();
 # or to limit the import to a subset of the defined import maps:
 $imp->run_import(qw/ cust /);

=head1 DESCRIPTION

Import data from schema 'src_schema' to schema 'dest_schema' using the maps
defined in the 'import_maps' array.

Use the 'lint' method to sanity check the import maps. Looks for possible
truncation, data loss, unreferenced columns, etc.

=head1 ATTRIBUTES

=cut

=head2 src_schema

The source DBIx::Class::Schema object.

=head2 dest_schema

The destination DBIx::Class::Schema object.

=head2 import_maps

A reference to an array of hash references with key-value pairs 'from_source'
and 'to_source', specifying source and destination schema source names, and
the 'map' key-value pair containing an array with a list of source accessor
and destination accessor or a reference to a callback subroutine.

The callback subroutine will be passed the value from the source data
column and should return the value to be stored in the destination.

=over

=item from_source

The schema source from which data are imported.

=item from_source_rs_method

Optional name of method to invoke against from_source schema to generate a
query to limit the source data set and a hash containing the arguments.

See L<DBIx::Class::ResultSet>

=item to_source

The schema source to which the imported data are stored.

=item map

A reference to an array of source accessor and target
specifiers. The target specifier may be either a target schema
accessor or a reference to a subroutine. The referent subroutine
will be passed the value of the source column.

=back

=cut

has 'src_schema' => (
    is          => 'ro',
    isa         => 'DBIx::Class::Schema',
    required    => 1,
);

has 'dest_schema' => (
    is          => 'ro',
    isa         => 'DBIx::Class::Schema',
    required    => 1,
);

has 'import_maps' => (
    is          => 'ro',
    isa         => ImportMapList,
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable();

sub BUILD {
    my ($self, $params) = @_;
    for my $import_map (@{$self->import_maps}) {
        next unless 1 & @{$import_map->{map}};
        DBIx::Class::Exception->throw(
            "error in map list, from_source => $import_map->{from_source}, "
            . "to_source => $import_map->{to_source}, "
            . '"map" attribute must be an even numbered list of pairs of '
            . 'source column name and destination column name or '
            . 'method call'
        );
    }
    for my $import_map (@{$self->import_maps}) {
        my ($n, @tuples, @map);
        @map = @{$import_map->{map}};
        $n = @map;
        for (my $i = 0; $i < $n; $i += 2) {
            push @tuples, [ @map[$i, $i + 1] ];
        }
        $import_map->{_map_tuples} = [ @tuples ];
    }
}

=head1 METHODS

=over

=item lint

Not yet implemented.

Check consistency of maps. Look for real or potential data loss.

=cut

sub lint {
}

=item run_import

Run the import. Pass a list of from_source names to limit the import to a
subset of the defined import maps.

=cut

# TODO new() modifier to validate map list
# TODO do INSERTs

sub run_import {
    my ($self, @wanted) = @_;

    # for each pair of tables (source & destination)
    for my $import_map (@{$self->import_maps}) {
        my $src = $import_map->{from_source};
        my $dst = $import_map->{to_source};
        my $ncols = @{$import_map->{_map_tuples}};
        my @srccol = map {$_->[0]} @{$import_map->{_map_tuples}};
        my $from_rs = $self->src_schema->resultset($src)
                           ->search(undef, { columns => [ @srccol ] });
        $from_rs = $self->_apply_from_source_rs_method($import_map, $from_rs);
        my $to_rs = $self->dest_schema->resultset($dst);
        $self->_import_rows($from_rs, $to_rs, $import_map);
    }
}

sub _import_rows {
    my ($self, $from_rs, $to_rs, $import_map) = @_;

    while (my $row = $from_rs->next) {
        my %insert;
        for my $t (@{$import_map->{_map_tuples}}) {
            my $src_col = $t->[0];
            if (ref $t->[1] eq 'ARRAY') {
                $insert{$t->[1][1]} = $t->[1][0]->($row->$src_col);
            }
            else {
                $insert{$t->[1]} = $row->$src_col;
            }
        }
        $to_rs->create({%insert});
    }
}

=back

=cut

sub _apply_from_source_rs_method {
    my ($self, $import_map, $from_rs) = @_;

    my ($meth, $args) = @{$import_map->{from_source_rs_method} || []};
    return $from_rs unless $meth;

    unless ($args) {
        DBIx::Class::Exception->throw(
            "error in from_source_rs_method, from_source => $import_map->{from_source}, "
            . "to_source => $import_map->{to_source}, no arguments were supplied for "
            . "the $meth method."
        );
    }

    return $from_rs->$meth($args);
}

sub _build_map_tuples {
    my ($self) = shift;

    my $ncols = @{$self->import_maps};
    for my $import_map (@{$self->import_maps}) {
        my @pair;
        for (my $i = 0; $i < $ncols; $i += 2) {
            push @pair, [ @{$import_map->{map}}[$i, $i+1] ];
        }
        $import_map->{_map_tuples} = [ @pair ];
    }
}

1;

__END__
=head1 AUTHOR

David P.C. Wollmann E<lt>converter42 at gmail dot comE<gt>

=head1 CONTRIBUTORS

mst and the crew on IRC who answer my silly questions.

=head1 COPYRIGHT

Copyright 2009 by David P.C. Wollmann

=head1 LICENSE

This library is free software and may be distributed under the same terms as perl itself.

