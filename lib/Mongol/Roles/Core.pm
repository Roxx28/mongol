package Mongol::Roles::Core {
	use Moose::Role;

	use MooseX::ClassAttribute;

	use Mongol::Cursor;

	requires 'pack';
	requires 'unpack';

	class_has 'collection' => (
		is => 'rw',
		isa => 'Maybe[MongoDB::Collection]',
		default => undef,
	);

	has 'id' => (
		is => 'rw',
		isa => 'Maybe[MongoDB::OID|Str|Num]',
		default => undef,
	);

	sub find {
		my ( $class, $query, $options ) = @_;

		my $result = $class->collection()
			->find( $query, $options )
			->result();

		return Mongol::Cursor->new(
			{
				class => $class,
				result => $result,
			}
		);
	}

	sub find_one {
		my ( $class, $query, $options ) = @_;

		my $document = $class->collection()
			->find_one( $query, {}, $options );

		return defined( $document ) ?
			$class->_map_to_object( $document ) :
			undef;
	}

	sub retrieve {
		my ( $class, $id ) = @_;

		return $class->find_one( { _id => $id } );
	}

	sub count {
		my ( $class, $query, $options ) = @_;

		return $class->collection()
			->count( $query, $options );
	}

	sub exists {
		my ( $class, $id ) = @_;

		return $class->count( { _id => $id } );
	}

	sub update {
		my ( $class, $filter, $update, $options ) = @_;

		my $result = $class->collection()
			->update_many( $filter, $update, $options );

		return $result->acknowledged() ?
			$result->modified_count() :
			undef;
	}

	sub delete {
		my ( $class, $filter ) = @_;

		my $result = $class->collection()
			->delete_many( $filter );

		return $result->acknowledged() ?
			$result->deleted_count() :
			undef;
	}

	sub save {
		my $self = shift();

		my $document = $self->pack();
		$document->{_id} = delete( $document->{id} );

		unless( defined( $document->{_id} ) ) {
			my $result = $self->collection()
				->insert_one( $document );

			$self->id( $result->inserted_id() );
		} else {
			$self->collection()
				->replace_one( { _id => $self->id() }, $document, { upsert => 1 } );
		}

		return $self;
	}

	sub remove {
		my $self = shift();

		$self->collection()
			->delete_one( { _id => $self->id() } );

		return $self;
	}

	sub drop {
		my $self = shift();

		$self->collection()
			->drop();
	}

	# --- Private
	sub _map_to_object {
		my ( $class, $document ) = @_;

		$document->{id} = delete( $document->{_id} );

		return $class->unpack( $document );
	}

	no Moose::Role;
}

1;

__END__

=pod

=head1 NAME

Mongol::Roles::Core - Core MongoDB actions and configuration

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 collection

=head2 id

=head1 METHODS

=head2 find

=head2 find_one

=head2 retrieve

=head2 count

=head2 exists

=head2 update

=head2 delete

=head2 save

=head2 remove

=head2 drop

=head1 SEE ALSO

=over 4

=item *

L<MongoDB::Collection>

=back

=cut
