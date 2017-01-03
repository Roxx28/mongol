package Mongol {
	use Moose;
	use Moose::Util qw( does_role );

	use Class::Load qw( load_class );

	our $VERSION = '2.0';

	sub map_entities {
		my ( $class, $connection, %entities ) = @_;

		while( my ( $package, $namespace ) = each( %entities ) ) {
			load_class( $package );

			if( does_role( $package, 'Mongol::Roles::Core' ) ) {
				$package->collection( $connection->get_namespace( $namespace ) );

				$package->setup()
					if( $package->can( 'setup' ) );
			}
		}
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=pod

=head1 NAME

Mongol - MongoDB ODM for Moose objects

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 map_entities

=head1 AUTHOR

Tudor Marghidanu <tudor@marghidanu.com>

=head1 SEE ALSO

=over 4

=item *

L<Moose>

=item *

L<MongoDB>

=back

=head1 LICENSE

This program is free software, you can redistribute it and/or modify it under the terms of the Artistic License version 2.0.

=cut
