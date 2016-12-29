package Mongol::Entity {
	use Moose::Role;

	use MooseX::ClassAttribute;

	use Mongol::Cursor;

	requires 'pack';

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
				_class => $class,
				_result => $result,
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

	sub count {
		my ( $class, $query, $options ) = @_;

		return $class->collection()
			->count( $query, $options );
	}

	sub retrieve {
		my ( $class, $id ) = @_;

		return $class->find_one( { _id => $id } );
	}

	sub exists {
		my ( $class, $id ) = @_;

		return $class->count( { _id => $id } );
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

	sub delete {
		my $self = shift();

		$self->collection()
			->delete_one( { _id => $self->id() } );

		return $self;
	}

	sub drop { shift()->collection()->drop() }

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

Mongol::Entity

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 EVENTS

=head1 ATTRIBUTES

=head2 collection

=head2 id

	my $id = $model->id();
	my $current_id = $model->id( '12345' );

=head1 METHODS

=head2 find

	my $cursor = Person->find( { age => 30 }, {} );

=head2 find_one

	my $model = Person->find( { name => 'John Doe' }, {} );

=head2 retrieve

	my $model = Person->retrieve( $id );

=head2 count

	my $count = Person->count( { age => '30' }, {} );

=head2 exists

	my $bool = Person->exists( $id );

=head2 save

	$model->age( 35 );
	$model->save();

=head2 delete

	$model->delete();

=head2 drop

	Person->drop();

=head1 SEE ALSO

=over 4

=item *

L<MongoDB::Collection>

=back

=cut
