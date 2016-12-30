package Mongol {
	use Moose;
	use Moose::Util qw( does_role );

	use Class::Load qw( load_class );

	our $VERSION = '1.3';

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

=head1 SYNOPSIS

	package Address {
		use Moose;

		extends 'Mongol::Base';

		has 'street' => (
			is => 'ro',
			isa => 'Str',
			required => 1,
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
			required => 1
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

		sub to_string {
			my $self = shift();

			sprintf( '%s %s', $self->first_name(), $self->last_name() );
		}

		__PACKAGE__->meta()->make_immutable();
	}

	...

	package main {
		use MongoDB;
		use Mongol;

		my $connection = MongoDB->connect( 'mongodb://localhost:27017' );

		Mongol->map_entities( $connection,
			'Person' => 'test.people',
			'Product' => 'test.product',
		);

		my $person = Person->new(
			{
				id => 616742,
				first_name => 'John',
				last_name => 'Doe',
				age => 30,
			}
		);

		my $home = Address->new(
			{
				street => 'Main St.',
				number => 123,
			}
		);

		$person->add( $address );
		$person->save();

		my $clone = Person->retrieve( 616742 );
		$clone->age( 31 );
		$clone->save();

		my $cursor = Person->find( { age => { '$gt' => 25 } } );
		while( my $person = $cursor->next() ) {
			printf( "%s : %d\n",
				$person->to_string(),
				$person->age()
			);

			$person->remove();
		}

		Person->drop();
	}

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

=head1 LICENSE

Same as perl.

=cut
