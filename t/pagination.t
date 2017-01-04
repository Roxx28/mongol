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

	require_ok( 'Mongol::Models::Person' );
	isa_ok( 'Mongol::Models::Person', 'Mongol::Model' );

	does_ok( 'Mongol::Models::Person', 'Mongol::Roles::Core' );
	does_ok( 'Mongol::Models::Person', 'Mongol::Roles::Pagination' );
	can_ok( 'Mongol::Models::Person', qw( paginate drop ) );

	require_ok( 'Mongol' );
	can_ok( 'Mongol', qw( map_entities ) );

	Mongol->map_entities( $mongo,
		'Mongol::Models::Person' => 'test.people',
	);

	Mongol::Models::Person->drop();

	foreach my $index ( 1 .. 50 ) {
		my $item = Mongol::Models::Person->new(
			{
				id => $index,
				first_name => 'Steve',
				last_name => 'Rogers',
				age => ( $index % 5 )
			}
		);

		$item->save();
	}

	my $collection = Mongol::Models::Person->paginate( { age => 0 }, 5, 3 );
	isa_ok( $collection, 'Mongol::Set' );
	isa_ok( $collection, 'Mongol::Model' );
	can_ok( $collection, qw( items start rows ) );

	is( $collection->total(), 10, 'Count ok' );
	is( $collection->start(), 5, 'Start ok' );
	is( $collection->rows(), 3, 'Rows ok' );

	my $data = [
		map { $_->id() }
			@{ $collection->items() }
	];
	is_deeply( $data, [ 30, 35, 40 ], 'Data ok' );

	Mongol::Models::Person->drop();

	done_testing();
}
