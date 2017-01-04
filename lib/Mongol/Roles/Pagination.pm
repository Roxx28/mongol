package Mongol::Roles::Pagination {
	use Moose::Role;

	use Mongol::Set;

	use constant {
		PAGINATION_DEFAULT_START => 0,
		PAGINATION_DEFAULT_ROWS => 10,
	};

	requires 'count';
	requires 'find';

	sub paginate {
		my ( $class, $query, $start, $rows, $options ) = @_;

		$options ||=  {};
		$options->{skip} = $start || PAGINATION_DEFAULT_START;
		$options->{limit} = $rows || PAGINATION_DEFAULT_ROWS;

		my $total = $class->count( $query );
		my @items = $class->find( $query, $options )
			->all();

		my $collection = Mongol::Set->new(
			{
				items => \@items,
				total => $total,
				start => $options->{skip},
				rows => $options->{limit},
			}
		);

		return $collection;
	}

	no Moose::Role;
}

1;

__END__

=pod

=head1 NAME

Mongol::Roles::Pagination - Pagination for Mongol models

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 paginate

=head1 SEE ALSO

=over 4

=item *

L<Mongol::Set>

=back

=cut
