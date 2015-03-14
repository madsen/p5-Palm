package Palm::DateTime;
#
# ABSTRACT: Deal with various Palm OS date/time formats
#
#	Copyright (C) 2001-2002, Alessandro Zummo <a.zummo@towertech.it>
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.

=head1 DESCRIPTION

Palm::DateTime exports subroutines to convert between various Palm OS
date/time formats.  All subroutines are exported by default.

Data types:

 secs     - Seconds since the system epoch
 dlptime  - Palm OS DlpDateTimeType (raw)
 datetime - Palm OS DateTimeType (raw)
 palmtime - Decoded date/time (a hashref)
              KEY     VALUES
              second  0-59
              minute  0-59
              hour    0-23
              day     1-31
              month   1-12
              year    4 digits

=cut

use strict;

use Exporter;
use POSIX;
use vars qw($VERSION);

# One liner, to allow MakeMaker to work.
$VERSION = '1.400';
# This file is part of {{$dist}} {{$dist_version}} ({{$date}})

@Palm::DateTime::ISA = qw( Exporter );

@Palm::DateTime::EXPORT = qw(

	datetime_to_palmtime

	dlptime_to_palmtime
	palmtime_to_dlptime

	secs_to_dlptime
	dlptime_to_secs

	palmtime_to_secs
	secs_to_palmtime

	palmtime_to_ascii
	palmtime_to_iso8601
);

=sub datetime_to_palmtime

  $palmtime = datetime_to_palmtime($datetime)

Converts Palm OS DateTimeType to a palmtime hashref.  In addition to
the usual keys, C<$palmtime> will contain a C<wday> field.

=cut

#FIXME what values can wday have?

sub datetime_to_palmtime
{
	my ($datetime) = @_;

	my $palmtime = {};

	@$palmtime
	{
		'second',
		'minute',
		'hour',
		'day',
		'month',
		'year',
		'wday',

	} = unpack("nnnnnnn", $datetime);

	return $palmtime;
}

=sub dlptime_to_palmtime

  $palmtime = dlptime_to_palmtime($dlptime)

Converts Palm OS DlpDateTimeType to a palmtime hashref.

=cut

sub dlptime_to_palmtime
{
	my ($dlptime) = @_;

	my $palmtime = {};

	@$palmtime
	{
		'year',
		'month',
		'day',
		'hour',
		'minute',
		'second',

	} = unpack("nCCCCCx", $dlptime);

	return $palmtime;
}

=sub palmtime_to_dlptime

  $dlptime = palmtime_to_dlptime(\%palmtime)

Converts a palmtime hashref to a Palm OS DlpDateTimeType.
C<%palmtime> must contain all standard fields.

=cut

# A future version might allow to specify only some of the fields.

sub palmtime_to_dlptime
{
	my ($palmtime) = @_;

	return pack("nCCCCCx", @$palmtime
				{
					'year',
					'month',
					'day',
					'hour',
					'minute',
					'second',
				});
}

=sub secs_to_dlptime

  $dlptime = secs_to_dlptime($secs)

Converts epoch time to a Palm OS DlpDateTimeType.

=cut

sub secs_to_dlptime
{
	my ($secs) = @_;

	return palmtime_to_dlptime(secs_to_palmtime($secs));
}

=sub dlptime_to_secs

  $secs = dlptime_to_secs($dlptime)

Converts a Palm OS DlpDateTimeType to epoch time.

=cut

sub dlptime_to_secs
{
	my ($dlptime) = @_;

	return palmtime_to_secs(dlptime_to_palmtime($dlptime));
}

=sub palmtime_to_secs

  $secs = palmtime_to_secs(\%palmtime)

Converts a palmtime hashref to epoch seconds.
C<%palmtime> must contain all standard fields.

=cut

sub palmtime_to_secs
{
	my ($palmtime) = @_;

	return POSIX::mktime(	$palmtime->{'second'},
				$palmtime->{'minute'},
				$palmtime->{'hour'},
				$palmtime->{'day'},
				$palmtime->{'month'} - 1,	# Palm used 1-12, mktime needs 0-11
				$palmtime->{'year'} - 1900,
				0,
				0,
				-1);
}

=sub secs_to_palmtime

  $palmtime = secs_to_palmtime($secs)

Converts epoch seconds to a palmtime hashref.

=cut

sub secs_to_palmtime
{
	my ($secs) = @_;

	my $palmtime = {};

	@$palmtime
	{
		'second',
		'minute',
		'hour',
		'day',
		'month',
		'year'
	} = localtime($secs);

	# Fix values
	$palmtime->{'year'}  += 1900;
	$palmtime->{'month'} += 1;

	return $palmtime;
}

=sub palmtime_to_ascii

  $string = palmtime_to_secs(\%palmtime)

Converts a palmtime hashref to a C<YYYYMMDDhhmmss> string
(e.g. C<20011116200051>).
C<%palmtime> must contain all standard fields.

=cut

sub palmtime_to_ascii
{
	my ($palmtime) = @_;

	return sprintf("%4d%02d%02d%02d%02d%02d",
		@$palmtime
		{
			'year',
			'month',
			'day',
			'hour',
			'minute',
			'second',
		});
}

=sub palmtime_to_iso8601

  $string = palmtime_to_iso8601(\%palmtime)

Converts a palmtime hashref to a C<YYYY-MM-DDThh:mm:ssZ> string
(e.g. C<2001-11-16T20:00:51Z>).
C<%palmtime> must contain all standard fields.
GMT timezone ("Z") is assumed.

=cut

sub palmtime_to_iso8601
{
	my ($palmtime) = @_;

	return sprintf("%4d-%02d-%02dT%02d:%02d:%02dZ",
		@$palmtime
		{
			'year',
			'month',
			'day',
			'hour',
			'minute',
			'second',
		});
}

1;
