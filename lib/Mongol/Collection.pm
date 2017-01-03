package Mongol::Collection {
	use Moose;

	extends 'Mongol::Model';

	has 'entities' => (
		is => 'ro',
		isa => 'ArrayRef[Mongol::Model]',
		default => sub { [] },
	);

	has 'total' => (
		is => 'ro',
		isa => 'Int',
		default => 0,
	);

	has 'start' => (
		is => 'ro',
		isa => 'Int',
		default => 0,
	);

	has 'rows' => (
		is => 'ro',
		isa => 'Int',
		default => 0,
	);

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=pod

=head1 NAME

Mongol::Collection - Result object for pagination

=head1 SYNOPSIS

=head1 DESCRIPTION

This object inherits form L<Mongol::Model> so you can use the serializatin/deserialization features.

=head1 ATTRIBUTES

=head2 items

	my $items = $collection->entities();

Returns a list of entities.

=head2 start

	my $start = $collection->start();


=head2 rows

	my $rows = $collection->rows();

=head1 SEE ALSO

=over 4

=item *

L<Mongol::Model>

=back

=cut
