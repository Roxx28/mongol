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
	can_ok( 'Item', qw( paginate  drop ) );

	require_ok( 'Mongol' );
	can_ok( 'Mongol', qw( map_entities ) );

	Mongol->map_entities( $mongo,
		'Item' => 'test.items',
	);

	Item->drop();

	foreach my $index ( 1 .. 20 ) {
		my $item = Item->new(
			{
				id => $index,
				name => sprintf( 'Item %d', $index ),
				number => ( $index % 2 )
			}
		);

		$item->save();
	}

	my $collection = Item->paginate( { number => 0 }, 5, 3 );
	isa_ok( $collection, 'Mongol::Collection' );
	isa_ok( $collection, 'Mongol::Base' );
	can_ok( $collection, qw( entities start rows ) );

	is( $collection->total(), 10, 'Count ok' );
	is( $collection->start(), 5, 'Start ok' );
	is( $collection->rows(), 3, 'Rows ok' );

	my $data = [ map { $_->id() } @{ $collection->entities() } ];
	is_deeply( $data, [ 12, 14, 16 ], 'Data ok' );

	Item->drop();

	done_testing();
}
