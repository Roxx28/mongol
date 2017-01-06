package Mongol::Model;

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

MooseX::Storage::Engine->add_custom_type_handler(
	'DateTime' => (
		expand => sub { shift() },
		collapse => sub { shift() },
	)
);

around 'pack' => sub {
	my $orig = shift();
	my $self = shift();

	my %args = @_;

	my $result = $self->$orig( %args );
	delete( $result->{__CLASS__} )
		if( $args{no_class} );

	return $result;
};

sub serialize { shift()->pack( no_class => 1 ) }

__PACKAGE__->meta()->make_immutable();

1;

__END__

=pod

=head1 NAME

Mongol::Model - Everything is a model

=head1 SYNOPSIS

	package Models::Person {
		use Moose;

		extends 'Mongol::Model';

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

		__PACKAGE__->meta()->make_immutable();
	}

=head1 DESCRIPTION

=head1 METHODS

=head2 pack

=head2 unpack

=head2 serialize

=head1 SEE ALSO

=over 4

=item *

L<MooseX::Storage>

=back

=cut
