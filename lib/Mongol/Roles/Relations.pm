package Mongol::Roles::Relations;

use Moose::Role;
use Moose::Util qw( does_role );

use Class::Load qw( load_class );

requires 'id';
requires 'find';
requires 'find_one';
requires 'retrieve';
requires 'delete';

sub has_many {
	my ( $class, $type, $foreign_key, $config ) = @_;

	load_class( $type );
	die( sprintf( '%s cannot do basic operations!', $type ) )
		unless( does_role( $type, 'Mongol::Roles::Core' ) );

	$class->meta()->add_method( get_children => sub {
			my ( $self, $query, $options ) = @_;

			$query ||= {};
			$query->{ $foreign_key } = $self->id();

			return $type->find( $query, $options );
		}
	);

	$class->meta()->add_method( get_child => sub {
			my ( $self, $id ) = @_;

			return $type->find_one(
				{
					_id => $id,
					$foreign_key => $self->id(),
				}
			);
		}
	);

	$class->meta()->add_method( remove_children => sub {
			my ( $self, $query ) = @_;

			$query ||= {};
			$query->{ $foreign_key } = $self->id();

			return $type->delete( $query );
		}
	);
}

sub has_one {
	my ( $class, $type, $foreign_key, $config ) = @_;

	load_class( $type );

	$class->meta()->add_method( 'get_parent' => sub {
			my $self = shift();

			return $type->retrieve( $self->$foreign_key() );
		}
	);
}

no Moose::Role;

1;

__END__

=pod

=head1 NAME

Mongol::Roles::Relations - Automatic relations builder

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 has_many

To be implemented.

=head2 has_one

To be implemented.

=head1 SEE ALSO

=over 4

=item *

L<MongoDB>

=back

=cut
