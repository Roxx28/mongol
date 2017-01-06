package Mongol::Roles::Core;

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
			type => $class,
			result => $result,
		}
	);
}

sub find_one {
	my ( $class, $query, $options ) = @_;

	my $document = $class->collection()
		->find_one( $query, {}, $options );

	return defined( $document ) ?
		$class->to_object( $document ) :
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
	my ( $class, $query, $update, $options ) = @_;

	my $result = $class->collection()
		->update_many( $query, $update, $options );

	return $result->acknowledged() ?
		$result->modified_count() :
		undef;
}

sub delete {
	my ( $class, $query ) = @_;

	my $result = $class->collection()
		->delete_many( $query );

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

sub to_object {
	my ( $class, $document ) = @_;

	$document->{id} = delete( $document->{_id} );

	return $class->unpack( $document );
}

no Moose::Role;

1;

__END__

=pod

=head1 NAME

Mongol::Roles::Core - Core MongoDB actions and configuration

=head1 SYNOPSIS

	package Models::Person {
		use Moose;

		extends 'Mongol::Model';

		with 'Mongol::Roles::Core';

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
			is => 'rw',
			isa => 'Int',
			default => 0,
		);

		__PACKAGE__->meta()->make_immutable();
	}

	...

	my $person = Models::Person->new(
		{
			first_name => 'Steve',
			last_name => 'Rogers',
		}
	);

	$person->save();
	printf( "User id: %s\n", $person->id()->to_string() )

	$person->age( 70 );
	$person->save();

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 collection

	my $collection = Models::Person->collection();

	my $collection = MongoDB->connect(...)
		->get_namespace( 'db.collection' );

	Models::Person->collection( $collection );

=head2 id

	my $id = $object->id();
	$object->id( $id );

=head1 METHODS

=head2 find

	my $cursor = Models::Person->find( $query, $options );

=head2 find_one

	my $object = Models::Person->find_one( $query, $options );

=head2 retrieve

	my $object = Models::Person->retrieve( $id );

=head2 count

	my $count = Models::Person->count( $query, $options );

=head2 exists

	my $bool = Models::Person->exists( $id );

=head2 update

	my $count = Models::Person->update( $query, $update, $options );

=head2 delete

	my $count = Models::Person->delete( $query );

=head2 save

	$object->save();

=head2 remove

	$object->remove();

=head2 drop

	Models::Person->drop();

=head2 to_object

	my $object = Models::Person->to_object( $hashref );

=head1 SEE ALSO

=over 4

=item *

L<MongoDB::Collection>

=back

=cut
