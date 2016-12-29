#!/usr/bin/env perl

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
		isa => 'Num',
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
		},
	);

	__PACKAGE__->meta()->make_immutable();
}

package main {
	use strict;
	use warnings;

	use MongoDB;

	use Mongol;

	use Data::Dumper;

	my $mongo = MongoDB->connect();

	Mongol->map_entities( $mongo,
		'Person' => 'test.people'
	);

	# Person->drop();

	my @objects = Person->find()
		->all();
	warn( Dumper( \@objects ) );

	my $person = Person->new(
		{
			first_name => 'John',
			last_name => 'Doe',
			age => 30,
		}
	);

	$person->add_address( Address->new( { street => 'Main St.', number => 123 } ) );
	$person->add_address( Address->new( { street => 'Infinit Loop', number => 1 } ) );
	$person->save();

	my $other_person = Person->retrieve( $person->id() );
	warn( Dumper( $other_person ) );
}
