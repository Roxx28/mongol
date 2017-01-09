#!/usr/bin/env perl

use strict;
use warnings;

use lib 't/lib';

use Test::More;
use Test::Moose;

use MongoDB;

use Mongol;
use Mongol::Test qw( check_mongod );

my $mongo = check_mongod();

Mongol->map_entities( $mongo,
	'Mongol::Models::Parent' => 'test.parents',
	'Mongol::Models::Child' => 'test.children',
);

require_ok( 'Mongol::Models::Parent' );
require_ok( 'Mongol::Models::Child' );

Mongol::Models::Parent->drop();
Mongol::Models::Child->drop();

my $parent = Mongol::Models::Parent->new( { name => 'Parent' } );

isa_ok( $parent, 'Mongol::Model' );
does_ok( $parent, 'Mongol::Roles::Core' );
does_ok( $parent, 'Mongol::Roles::Relations' );

can_ok( $parent, qw( save get_children get_child remove_children ) );
$parent->save();

foreach my $index ( 1 .. 10 ) {
	my $child = Mongol::Models::Child->new(
		{
			id => $index,
			parent_id => ( $index % 2 ) ? $parent->id() : undef,
			name => sprintf( 'Child %d', $index ),
		}
	);

	$child->save();
}

my @children = $parent->get_children()
	->all();

is( scalar( @children ), 5, 'Count ok' );
is_deeply(
	[ map { $_->id() } @children ],
	[ 1, 3, 5, 7, 9 ],
	'Ids match!'
);

my $first = $parent->get_child( 1 );
isa_ok( $first, 'Mongol::Models::Child' );
can_ok( $first, qw( get_parent ) );
is( $first->id(), 1, 'First record found' );

is_deeply( $first->get_parent(), $parent, 'Parent ok' );

$parent->remove_children();
@children = $parent->get_children()
	->all();

is_deeply( \@children, [], 'Removed children' );

done_testing();
