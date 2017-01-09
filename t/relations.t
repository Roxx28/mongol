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

my $parent = Mongol::Models::Parent->new(
	{
		name => 'Parent'
	}
);

isa_ok( $parent, 'Mongol::Model' );
does_ok( $parent, 'Mongol::Roles::Core' );
does_ok( $parent, 'Mongol::Roles::Relations' );

can_ok( $parent, qw( save get_children get_child remove_children ) );
$parent->save();

done_testing();
