package Mongol::Cursor {
	use Moose;

	has '_result' => (
		is => 'ro',
		isa => 'MongoDB::QueryResult',
		required => 1,
	);

	has '_class' => (
		is => 'ro',
		isa => 'Str',
		required => 1,
	);

	sub all {
		my $self = shift();

		return map { $self->_class()->_map_to_object( $_ ) }
			$self->_result()->all();
	}

	sub has_next {
		my $self = shift();

		return $self->_result()
			->has_next()
	}

	sub next {
		my $self = shift();

		my $document = $self->_result()
			->next();

		return defined( $document ) ?
			$self->_class()->_map_to_object( $document ) : undef;
	}

	__PACKAGE__->meta()->make_immutable();
}

1;

__END__

=pod

=head1 NAME

Mongol::Cursor - Object cursor

=head1 SYNOPSIS

	package Person {
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

	my $cursor = Person->find( { age => { '$lt' => 30 } } );
	while( ( my $person = $cursor->next() ) ) {
		printf( "Name: %s\n", $person->name() );
		printf( "Age: %d\n", $person->age() );
	}

	my @people = $cursor->all();

=head1 DESCRIPTION

=head1 METHODS

=head2 all

	my @objects = $cursor->all();

=head2 has_next

	my $bool = $cursor->has_next();

=head2 next

	my $object = $cursor->next();

=head1 SEE ALSO

=over 4

=item *

L<MongoDB::Cursor>

=item *

L<MongoDB::QueryResult>

=back

=cut
