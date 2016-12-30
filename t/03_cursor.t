#!/usr/bin/env perl

package Item {
	use Moose;

	extends 'Mongol::Base';

	with 'Mongol::Entity';

	has 'name' => (
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

	require_ok( 'Item' );
	isa_ok( 'Item', 'Mongol::Base' );

	does_ok( 'Item', 'Mongol::Entity' );
	has_attribute_ok( 'Item', 'id' );
	has_attribute_ok( 'Item', 'name' );
	has_attribute_ok( 'Item', 'number' );

	can_ok( 'Item', qw( save drop find ) );

	require_ok( 'Mongol' );
	can_ok( 'Mongol', qw( map_entities ) );

	Mongol->map_entities( $mongo,
		'Item' => 'test.items',
	);

	Item->drop();

	foreach my $index ( 1 .. 50 ) {
		my $item = Item->new(
			{
				id => $index,
				name => sprintf( 'Item %d', $index ),
				number => $index % 5,
			}
		);

		$item->save();
	}

	my $cursor = Item->find( { number => 0 } );
	isa_ok( $cursor, 'Mongol::Cursor' );
	can_ok( $cursor, qw( all has_next next ) );

	my $index = 1;
	while( my $current = $cursor->next() ) {
		isa_ok( $current, 'Item' );

		my $value = $index++ * 5;
		is( $current->id(), $value, sprintf( 'Match on value: %d', $value ) );
	}

	my @items = Item->find( { number => 0 } )
		->all();
	is( scalar( @items ), 10, 'Counts match' );

	done_testing();
}
