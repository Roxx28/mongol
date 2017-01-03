#!/usr/bin/env perl

package main {
	use strict;
	use warnings;

	use lib 't/lib';

	use Test::More;
	use Test::Moose;

	use MongoDB;

	use Mongol::Test qw( check_mongod );

	my $mongo = check_mongod();

	require_ok( 'Mongol::Models::Hero' );
	isa_ok( 'Mongol::Models::Hero', 'Mongol::Model' );

	does_ok( 'Mongol::Models::Hero', 'Mongol::Roles::Basic' );
	has_attribute_ok( 'Mongol::Models::Hero', 'id' );
	has_attribute_ok( 'Mongol::Models::Hero', 'first_name' );
	has_attribute_ok( 'Mongol::Models::Hero', 'last_name' );
	has_attribute_ok( 'Mongol::Models::Hero', 'age' );

	can_ok( 'Mongol::Models::Hero', qw( save drop find ) );

	require_ok( 'Mongol' );
	can_ok( 'Mongol', qw( map_entities ) );

	Mongol->map_entities( $mongo,
		'Mongol::Models::Hero' => 'test.people',
	);

	Mongol::Models::Hero->drop();

	foreach my $index ( 1 .. 50 ) {
		my $item = Mongol::Models::Hero->new(
			{
				id => $index,
				first_name => 'Tony',
				last_name => 'Stark',
				age => $index % 5,
			}
		);

		$item->save();
	}

	my $cursor = Mongol::Models::Hero->find( { age => 0 } );
	isa_ok( $cursor, 'Mongol::Cursor' );
	can_ok( $cursor, qw( all has_next next ) );

	my $index = 1;
	while( my $person = $cursor->next() ) {
		isa_ok( $person, 'Mongol::Models::Hero' );

		my $value = $index++ * 5;
		is( $person->id(), $value, sprintf( 'Match on value: %d', $value ) );
	}

	my @people = Mongol::Models::Hero->find( { age => 1 } )
		->all();
	is( scalar( @people ), 10, 'Counts match' );

	Mongol::Models::Hero->drop();

	done_testing();
}
