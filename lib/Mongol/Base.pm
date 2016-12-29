package Mongol::Base {
	use Moose;

	use MooseX::Storage;
	use MooseX::Storage::Engine;

	with Storage( base => 'SerializedClass' );

	MooseX::Storage::Engine->add_custom_type_handler(
		'MongoDB::OID' => (
			expand => sub { shift() },
			collapse => sub { shift() },
		)
	);

	MooseX::Storage::Engine->add_custom_type_handler(
		'MongoDB::DBRef' => (
			expand => sub { shift() },
			collapse => sub { shift() },
		)
	);

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=pod

=head1 NAME

Mongol::Base - Base class for Mongol entities

=head1 SYNOPSIS

	package My::Model::Person {
		use Moose;

		extends 'Mongol::Base';

		has 'name' => (
			is => 'ro',
			isa => 'Str',
			required => 1,
		);

		has 'age' => (
			is => 'ro',
			isa => 'Int',
			required => 1,
		);

		__PACKAGE__->meta()->make_immutable();
	}

	...

	my $person = Person->new( { name => 'John Doe', age => 30 } );
	my $data = $person->pack();

	my $other_person = Person->unpack( $data );

=head1 DESCRIPTION

ALl Mongol entitities should inherit from this class since this takes care of the
serializiation/deserialization of the objects. The serialization is provided by
L<MooseX::Storage> together with L<MooseX::Storage::Base::SerializedClass>, this
way we don't have to worry about coercions and defining custom subtypes.

But this comes with a price since L<MooseX::Storage> adds an additional field for
each object which contains the class name.

=head1 METHODS

=head2 pack

	$model->pack()

Inherited from L<MooseX::Storage>.

=head2 unpack

	$model->unpack();

Inherited from L<MooseX::Storage>.

=head1 SEE ALSO

=over 4

=item *

L<Moose>

=item *

L<MooseX::Storage>

=item *

L<MooseX::Storage::Engine>

=back

=cut
