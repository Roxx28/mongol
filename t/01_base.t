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
		isa => 'Int',
		required => 1,
	);

	__PACKAGE__->meta()->make_immutable();
}

package Person {
	use Moose;

	extends 'Mongol::Base';

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

	has 'address' => (
		is => 'ro',
		isa => 'Address',
		required => 1,
	);

	sub to_string {
		my $self = shift();

		return sprintf( '%s %s',
			$self->first_name(),
			$self->last_name()
		);
	}

	__PACKAGE__->meta()->make_immutable();
}

package main {
	use strict;
	use warnings;

	use Test::More;
	use Test::Moose;

	require_ok( 'Address' );
	my $address = Address->new(
		{
			street => 'Main St.',
			number => 123
		}
	);

	isa_ok( $address, 'Address' );
	can_ok( $address, qw( street number ) );

	isa_ok( $address, 'Mongol::Base' );
	can_ok( $address, qw( pack unpack serialize ) );

	require_ok( 'Person' );
	my $person = Person->new(
		{
			first_name => 'Peter',
			last_name => 'Parker',
			age => 25,
			address => $address,
		}
	);

	isa_ok( $person, 'Person' );
	has_attribute_ok( $person, 'first_name' );
	has_attribute_ok( $person, 'last_name' );
	has_attribute_ok( $person, 'age' );
	can_ok( $person, qw( to_string ) );

	isa_ok( $person, 'Mongol::Base' );
	can_ok( $person, qw( pack unpack serialize ) );

	my $data = {
		first_name => 'Peter',
		last_name => 'Parker',
		age => 25,
		address => {
			street => 'Main St.',
			number => 123,
		}
	};
	is_deeply( $person->pack( no_class => 1 ), $data , 'Object serialized correctly (unpack)' );
	is_deeply( $person->serialize(), $data , 'Object serialized correctly (serialize)' );

	is( $person->to_string(), 'Peter Parker', 'Instance methods work correctly' );

	done_testing();
}
