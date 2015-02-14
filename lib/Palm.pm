package Palm;
#
# ABSTRACT: Palm OS utility functions
#
#	Copyright (C) 1999, 2000, Andrew Arensburger.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.

use strict;
use warnings;
use vars qw( $VERSION );

# One liner, to allow MakeMaker to work.
$VERSION = '1.015';
# This file is part of {{$dist}} {{$dist_version}} ({{$date}})

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut

my $EPOCH_1904 = 2082844800;		# Difference between Palm's
					# epoch (Jan. 1, 1904) and
					# Unix's epoch (Jan. 1, 1970),
					# in seconds.

=head2 palm2epoch

	my @parts = localtime( palm2epoch($palmtime) );

Converts a S<Palm OS> timestamp to a Unix Epoch time. Note, however, that S<Palm OS>
time is in the timezone of the Palm itself while Epoch is defined to be in
the GMT timezone. Further conversion may be necessary.

=cut

sub palm2epoch {
	return $_[0] - $EPOCH_1904;
}

=head2 epoch2palm

	my $palmtime = epoch2palm( time() );

Converts Unix epoch time to Palm OS time.

=cut

sub epoch2palm {
	return $_[0] + $EPOCH_1904;
}

=head2 mkpdbname

	$PDB->Write( mkpdbname($PDB->{name}) );

Convert a S<Palm OS> database name to a 7-bit ASCII representation. Native
Palm database names can be found in ISO-8859-1 encoding. This encoding
isn't going to generate the most portable of filenames and, in particular,
ColdSync databases use this representation.

=cut

sub mkpdbname {
	my $name = shift;
	$name =~ s![%/\x00-\x19\x7f-\xff]!sprintf("%%%02X",ord($&))!ge;
	return $name;
}

=head1 SEE ALSO

L<Palm::PDB>

=cut

1;
