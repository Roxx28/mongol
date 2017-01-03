package Mongol::Cursor {
	use Moose;

	has 'result' => (
		is => 'ro',
		isa => 'MongoDB::QueryResult',
		required => 1,
	);

	has 'class' => (
		is => 'ro',
		isa => 'Str',
		required => 1,
	);

	sub all {
		my $self = shift();

		return map { $self->class()->_map_to_object( $_ ) }
			$self->result()->all();
	}

	sub has_next {
		my $self = shift();

		return $self->_result()
			->has_next()
	}

	sub next {
		my $self = shift();

		my $document = $self->result()
			->next();

		return defined( $document ) ?
			$self->class()->_map_to_object( $document ) : undef;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=pod

=head1 NAME

Mongol::Cursor - Mongol cursor wrapper

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 class

=head2 result

=head1 METHODS

=head2 all

=head2 has_next

=head2 next

=head1 SEE ALSO

=over 4

=item *

L<MongoDB::Cursor>

=item *

L<MongoDB::QueryResult>

=back

=cut
