package Mongol::Collection {
	use Moose;

	extends 'Mongol::Base';

	has 'entities' => (
		is => 'ro',
		isa => 'ArrayRef[Mongol::Base]',
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
		default => 10,
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

This object inherits form L<Mongol::Base> so you can use the serializatin/deserialization features.

=head1 ATTRIBUTES

=head2 items

	my $items = $collection->entities();

Returns a list of entities.

=head2 start

	my $start = $collection->start();


Pagination start index. Defaults to 0.

=head2 rows

	my $rows = $collection->rows();

Returns the number of rows. Default to 10.

=head1 SEE ALSO

=over 4

=item *

L<Mongol::Base>

=back

=cut
