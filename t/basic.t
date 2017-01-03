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

	does_ok( 'Mongol::Models::Hero', 'Mongol::Roles::Core' );
	has_attribute_ok( 'Mongol::Models::Hero', 'id' );

	# NOTE: "class_has" does not register an normal attribute.
	# This is why I need to check it this way ...
	can_ok( 'Mongol::Models::Hero', qw(
			collection
			find find_one count retrieve exists
			save delete
			drop
		)
	);

	require_ok( 'Mongol' );
	can_ok( 'Mongol', qw( map_entities ) );

	Mongol->map_entities( $mongo,
		'Mongol::Models::Hero' => 'test.people',
	);

	# We start with a clean collection
	Mongol::Models::Hero->drop();

	my $product = Mongol::Models::Hero->new(
		{
			first_name => 'Bruce',
			last_name => 'Banner',
			age => 36,
		}
	);
	isa_ok( $product, 'Mongol::Models::Hero' );
	has_attribute_ok( $product, 'id' );
	has_attribute_ok( $product, 'first_name' );
	has_attribute_ok( $product, 'last_name' );
	has_attribute_ok( $product, 'age' );

	$product->save();
	isa_ok( $product->id(), 'MongoDB::OID' );

	$product->age( 37 );
	$product->save();

	# Two save calls in a row but only one record ...
	is( Mongol::Models::Hero->count(), 1, 'Count should be 1' );

	my $clone = Mongol::Models::Hero->retrieve( $product->id() );
	is_deeply( $clone, $product, 'Objects match' );

	$product->remove();
	is( Mongol::Models::Hero->count(), 0, 'Count should be 0' );

	Mongol::Models::Hero->drop();

	done_testing();
}
