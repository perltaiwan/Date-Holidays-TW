package Date::Holidays::TW;
use strict;
use utf8;

our $VERSION = v0.1.1;

use Exporter 'import';
our @EXPORT_OK = qw(is_tw_holiday tw_holidays);

use DateTime;
use DateTime::Calendar::Chinese;

my %NATIONAL = (
    '0101' => '中華民國開國紀念日',
    '0228' => '和平紀念日',
    '0404' => '兒童節',
    '1010' => '國慶日',
);

my %FOLK_LUNAR = (
    '0101' => '春節',
    '0102' => '春節',
    '0103' => '春節',
    '0505' => '端午節',
    '0815' => '中秋節',
    '1230' => '農曆除夕',
    # '????' => '清明節' (民族掃墓節)
);

my %CAL = (
    2017 => {
        "0101" => "中華民國開國紀念日",
        "0102" => "調整放假",
        "0127" => "農曆除夕",
        "0128" => "春節",
        "0129" => "春節",
        "0130" => "春節",
        "0131" => "春節",
        "0201" => "春節",
        "0227" => "調整放假",
        "0228" => "和平紀念日",
        "0403" => "調整放假",
        "0404" => "民族掃墓節",
        "0529" => "調整放假",
        "0530" => "端午節",
        "1004" => "中秋節",
        "1009" => "調整放假",
        "1010" => "國慶日",
    },
    2018 => {
        "0101" => "中華民國開國紀念日",
        "0215" => "農曆除夕",
        "0216" => "春節",
        "0217" => "春節",
        "0218" => "春節",
        "0219" => "春節",
        "0220" => "春節",
        "0228" => "和平紀念日",
        "0301" => "和平紀念日",
        "0404" => "兒童節",
        "0405" => "民族掃墓節",
        "0405" => "調整放假",
        "0618" => "端午節",
        "0924" => "中秋節",
        "1010" => "國慶日",
    },
    2019 => {
        "0101" => "中華民國開國紀念日",
        "0204" => "農曆除夕",
        "0205" => "春節",
        "0206" => "春節",
        "0207" => "春節",
        "0208" => "春節",
        "0228" => "和平紀念日",
        "0301" => "和平紀念日",
        "0404" => "兒童節",
        "0405" => "民族掃墓節",
        "0607" => "端午節",
        "0913" => "中秋節",
        "1010" => "國慶日",
        "1011" => "國慶日",
    },
    2020 => {
        "0101" => "中華民國開國紀念日",
        "0123" => "農曆除夕",
        "0124" => "農曆除夕",
        "0125" => "春節",
        "0126" => "春節",
        "0127" => "春節",
        "0128" => "春節",
        "0129" => "春節",
        "0228" => "和平紀念日",
        "0402" => "兒童節",
        "0403" => "兒童節",
        "0404" => "兒童節",
        "0625" => "端午節",
        "0626" => "端午節",
        "1001" => "中秋節",
        "1002" => "中秋節",
        "1009" => "國慶日",
        "1010" => "國慶日"
    },
);

sub new { bless {}, shift };

sub holidays {
    my (undef, $year) = @_;
    return tw_holidays($year);
}

sub is_holiday {
    my (undef, $year, $month, $day) = @_;
    return is_tw_holiday($year, $month, $day);
}

my %_reified;
sub tw_holidays {
    my ($year) = @_;
    $year = sprintf('%04d', $year);

    unless ($_reified{$year}) {
        my %holidays = %NATIONAL;

        my $dt = DateTime->new( year => $year, month => 1, day => 1, time_zone => 'Asia/Taipei' );
        while ($dt->year == $year) {
            my $h = __is_tw_holiday($dt);
            if (defined($h)) {
                my $mmdd = $dt->strftime('%m%d');
                $holidays{$mmdd} = $h;
            }

            $dt->add(days => 1);
        }

        $_reified{$year} = \%holidays;
    }

    return $_reified{$year};
}

sub is_tw_holiday {
    my ($year, $month, $day) = @_;
    return __is_tw_holiday(
        DateTime->new(
            year => $year,
            month => $month,
            day => $day,
            time_zone => 'Asia/Taipei',
        )
    );
}

sub __is_tw_holiday {
    my ($dt) = @_;
    my $mmdd = $dt->strftime('%m%d');
    my $year = $dt->year;
    return $CAL{$year}{$mmdd} // $NATIONAL{$mmdd} // __is_qingming($dt) // __is_tw_lunar_holiday($dt)
}

sub __is_tw_lunar_holiday {
    my ($dt) = @_;
    my $lunar_date = DateTime::Calendar::Chinese->from_object(object => $dt);
    return undef if $lunar_date->leap_month;
    my $lunar_mmdd = sprintf('%02d%02d', $lunar_date->month, $lunar_date->day);
    return $FOLK_LUNAR{$lunar_mmdd};
}

sub __is_qingming {
    # Thanks Wei-Hon Chen for the formula.
    my $dt = $_[0];
    return undef unless $dt->month == 4 && 3 < $dt->day && $dt->day < 6;
    my $year = $dt->year;
    die "Unsupported" if $year < 1901 || 2100 < $year;
    my $Y = ($year % 100);
    my $C = (1901 <= $year && $year < 2001) ? 5.59 : 4.81;
    my $n = int($Y * 0.2422 + 4.81) - int($Y / 4);
    return $dt->day == $n ? '民族掃墓節' : undef;
}

1;

__END__

=head1 NAME

Date::Holidays::TW - Determine whether it is Taiwan Holidays or not.

=head1 SYNOPSIS

This module can be used by itself:

    use Date::Holidays::TW qw(is_tw_holiday);
    if ( is_tw_holiday(2020, 6, 25) ) {
        ...
    }

Or via C<Date::Holidays>

    my $dh = Date::Holidays->new( countrycode => 'TW' );
    if ($dh->is_holiday( 2020, 6, 25 )) {
        ...
    }

=head1 DESCRIPTION

This module provides functions to look into Taiwan holiday calendars
for known holidays. It could be used by itself, or under via
L<Date::Holidays> module.

Caveat: Due to the rule of weekend-compensation and the fact that the
majority of holidays are defined by Chinese calendar (Lunar), it
requires some non-trivial amount of computation to correctly determine
whether the given date is an holiday or not -- which is not
implemented at this version.

The current implementation includes all known holidays of year 2019
and 2020 as a lookup table and should therefore correctly determine
holidays in those 2 years. It should also determine most of the future
updates correct by some basic compuation, except for the ones
generated by the weekend-compensation rule.

Conventionally the holiday calendar for the next year is announcend at
the end of June and we could start to mix the new information into the
lookup table in this module.

Generally speaking, queries for far future should be avoided.

=head1 EXPORTABLE FUNCTIONS

=head2 is_tw_holiday

Usage:

    my $holiday_name = is_tw_holiday( $year, $month, $day );

This subroutine returns the name of the holiday for the given day
if it is a holiday. Otherwise it returns undef.

=head2 tw_holidays

Usage:

    my $holidays = tw_holidays( $year );

This retrieve all Taiwan holidays of given year as a HashRef.
With keys being Month + Day as 4-digit string and values being
the name of the corresponding holiday.

=head1 METHODS

=head2 is_holiday

Usage:

    $o = Date::Holidays::TW->new();
    $res = $o->is_holiday( $year, $month, $day );

This does the same thing as function C<is_tw_holiday>.

=head2 holidays

Usage:

    $o = Date::Holidays::TW->new();
    $res = $o->holidays( $year );

This does the same thing as function C<tw_holidays>.

=head1 SEE ALSO

L<Date::Holidays>, L<https://www.dgpa.gov.tw/informationlist?uid=30>

=head1 AUTHOR

Kang-min Liu C<< <gugod@gugod.org> >>

Wei-Hon Chen

=head1 LICENSE

The MIT License

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
