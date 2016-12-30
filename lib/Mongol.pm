package Mongol {
	use Moose;
	use Moose::Util qw( does_role );

	use Class::Load qw( load_class );

	our $VERSION = '1.1';

	sub map_entities {
		my ( $class, $connection, %entities ) = @_;

		while( my ( $package, $namespace ) = each( %entities ) ) {
			load_class( $package );

			$package->collection( $connection->get_namespace( $namespace ) )
				if( does_role( $package, 'Mongol::Entity' ) );
		}
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=pod

=head1 NAME

Mongol - Basic Mongo ODM for Moose objects

=head1 VERSION

1.0

=head1 SYNOPSIS

=head1 DESCRIPTION

L<Mongol> is a basic MongoDB ODM for Moose objects.

=head1 METHODS

=head2 map_entities

	Mongol->map_entities( $mongo_connection,
		'My::Moose::Object' => 'database.collection'
	)

Maps a Moose class with the L<Mongol::Entity> applied to a MongoDB collection. You can add multiple entities
for the same collection if you want to map object partially.

=head1 AUTHOR

Tudor Marghidanu <tudor at marghidanu.com>

=head1 SEE ALSO

=over 4

=item *

L<Moose>

=item *

L<MongoDB>

=back

=cut
