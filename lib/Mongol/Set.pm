package Mongol::Set;

use Moose;

extends 'Mongol::Model';

has 'items' => (
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

1;

__END__

=pod

=head1 NAME

Mongol::Set - Result object for pagination

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 items

	my $array_ref = $set->items();

=head2 start

	my $start = $set->start();

=head2 rows

	my $rows = $set->rows();

=head1 SEE ALSO

=over 4

=item *

L<Mongol::Model>

=back

=cut
