package Mongol::Entity {
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

	package Address {
		use Moose;

		extends 'Mongol::Base';

		has 'street' => (
			is => 'ro',
			isa => 'Str',
			required => 1
		);

		has 'number' => (
			is => 'ro',
			isa => 'Int',
			required => 1,
		);

		__PACKAGE__->meta()->make_immutable();
	}

	package Person {
		use Moose;

		extends 'Mongol::Base';

		with 'Mongol::Entity';

		has 'first_name' => (
			is => 'ro',
			isa => 'Str',
			required => 1,
		);

		has 'last_name' => (
			is => 'ro',
			isa => 'Str',
			required => 1,
		);

		has 'age' => (
			is => 'ro',
			isa => 'Int',
			required => 1,
		);

		has 'addresses' => (
			is => 'ro',
			isa => 'ArrayRef[Address]',
			default => sub { [] },
			traits => [ qw( Array ) ],
			handles => {
				add_address => 'push',
			}
		);

		__PACKAGE__->meta()->make_immutable();
	}

	...

	my $person = Person->new(
		{
			id => 6161742,
			first_name => 'John',
			last_name => 'Doe',
			age => 30,
		}
	);

	my $home = Address->new(
		{
			street => 'Main St.',
			number => 123
		}
	);

	# --- Saving
	$person->add_address( $home );
	$person->save();

	$person->age( 31 );
	$person->save();

	# --- Reading
	my $other = Person->retrive( 616742 );

=head1 DESCRIPTION

=head1 EVENTS

None at this moment.

=head1 ATTRIBUTES

=head2 collection

	Person->collection()

MongoDB collection class attribute. It contains the L<MongoDB::Collection> associated
with this entity.

=head2 id

	my $id = $model->id();
	my $current_id = $model->id( '12345' );

=head1 METHODS

=head2 find

	my $cursor = Person->find( { age => 30 }, {} );

Executes the mongo query returning a L<Mongol::Cursor> object. Supports the same
parameters as the B<find> method definded in the L<MongoDB::Collection> package.

=head2 find_one

	my $model = Person->find( { name => 'John Doe' }, {} );

=head2 retrieve

	my $model = Person->retrieve( $id );

=head2 count

	my $count = Person->count( { age => '30' }, {} );

=head2 exists

	my $bool = Person->exists( $id );

=head2 update

=head2 delete

	my $count = Person->delete( { age => { '$gt' => 30 } } );

=head2 save

	$model->age( 35 );
	$model->save();

=head2 remove

	$model->remove();

=head2 drop

	Person->drop();

Drops the MongoDB collection associated to this entity.

=head1 SEE ALSO

=over 4

=item *

L<MongoDB::Collection>

=item *

L<MooseX::ClassAttribute>

=back

=cut
