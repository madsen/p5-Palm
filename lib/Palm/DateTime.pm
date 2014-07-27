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
#
# Data types:
#
#  secs		- Seconds since whatever time the system considers to be The Epoch
#  dlptime	- Palm OS DlpDateTimeType (raw)
#  datetime	- Palm OS DateTimeType (raw)
#  palmtime	- Decoded date/time

use strict;

use Exporter;
use POSIX;
use vars qw($VERSION);

# One liner, to allow MakeMaker to work.
$VERSION = '1.014';
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

# This one takes a palmtime structure, which must be completely filled in.
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

sub secs_to_dlptime
{
	my ($secs) = @_;

	return palmtime_to_dlptime(secs_to_palmtime($secs));
}

sub dlptime_to_secs
{
	my ($dlptime) = @_;

	return palmtime_to_secs(dlptime_to_palmtime($dlptime));
}

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

# This one gives out something like 20011116200051
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
# IS8601 compliant: 2001-11-16T20:00:51Z
# GMT timezone ("Z") is assumed. XXX ?
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
