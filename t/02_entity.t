#!/usr/bin/env perl

package Product {
	use Moose;

	extends 'Mongol::Base';

	with 'Mongol::Entity';

	has 'name' => (
		is => 'ro',
		isa => 'Str',
		required => 1,
	);

	has 'description' => (
		is => 'ro',
		isa => 'Maybe[Str]',
		default => undef,
	);

	has 'price' => (
		is => 'rw',
		isa => 'Num',
		default => 0.00,
	);

	__PACKAGE__->meta()->make_immutable();
}

package main {
	use strict;
	use warnings;

	use Test::More;
	use Test::Moose;

	use MongoDB;

	my $mongo;
	eval {
		$mongo = MongoDB->connect( $ENV{MONGOL_URL} || 'mongodb://localhost' );
		$mongo->db( 'test' )
			->run_command( [ ping => 1 ] );
	};

	plan skip_all => 'Cannot connect to mongo!'
		if( $@ );

	require_ok( 'Product' );
	isa_ok( 'Product', 'Mongol::Base' );

	does_ok( 'Product', 'Mongol::Entity' );
	has_attribute_ok( 'Product', 'id' );

	# NOTE: "class_has" does not register an normal attribute.
	# This is why I need to check it this way ...
	can_ok( 'Product', qw(
			collection
			find find_one count retrieve exists paginate
			save delete
			drop
		)
	);

	require_ok( 'Mongol' );
	can_ok( 'Mongol', qw( map_entities ) );

	Mongol->map_entities( $mongo,
		'Product' => 'test.products',
	);

	# We start with a clean collection
	Product->drop();

	my $product = Product->new(
		{
			name => 'Pants',
			price => 35.67
		}
	);
	isa_ok( $product, 'Product' );
	has_attribute_ok( $product, 'id' );
	has_attribute_ok( $product, 'name' );
	has_attribute_ok( $product, 'description' );
	has_attribute_ok( $product, 'price' );

	$product->save();
	isa_ok( $product->id(), 'MongoDB::OID' );

	$product->price( 12.34 );
	$product->save();

	# Two save calls in a row but only one record ...
	is( Product->count(), 1, 'Count should be 1' );

	my $clone = Product->retrieve( $product->id() );
	is_deeply( $clone, $product, 'Objects match' );

	$product->remove();
	is( Product->count(), 0, 'Count should be 0' );

	Product->drop();

	done_testing();
}
