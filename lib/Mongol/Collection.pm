package Mongol::Collection {
	use Moose;

	extends 'Mongol::Base';

	has 'items' => (
		is => 'ro',
		isa => 'ArrayRef[Mongol::Base]',
		default => sub { [] },
		traits => [ qw( Array ) ],
		handles => {
			all_items => 'elements',
		}
	);

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=pod

=head1 NAME

Mongol::Collection

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 items

	my $items = $collection->items()

=head1 METHODS

=head2 all_items

	my @items = $collection->all_items()

=head1 SEE ALSO

=over 4

=item *

L<Mongol::Base>

=back

=cut
