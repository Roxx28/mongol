package Mongol::Models::Child;

use Moose;

extends 'Mongol::Model';

with 'Mongol::Roles::Core';
with 'Mongol::Roles::Relations';

has 'parent_id' => (
	is => 'ro',
	isa => 'MongoDB::OID',
	required => 1,
);

has 'name' => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);

__PACKAGE__->meta()->make_immutable();

1;
