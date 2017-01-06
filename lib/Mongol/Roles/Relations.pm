package Mongol::Roles::Relations;

use Moose::Role;
use Moose::Util;

use Class::Load qw( load_class );

sub has_many {
	my ( $class, $type, $foreign_key, $config ) = @_;
}

sub has_one {
	my ( $class, $type, $foreign_key, $config ) = @_;
}

no Moose::Role;

1;

__END__

=pod

=head1 NAME

Mongol::Roles::Relations - Automatic relations builder

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 has_many

To be implemented.

=head2 has_one

To be implemented.

=head1 SEE ALSO

=over 4

=item *

L<MongoDB>

=back

=cut
