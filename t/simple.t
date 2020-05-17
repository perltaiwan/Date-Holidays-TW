use Test2::V0;

use Date::Holidays::TW qw(is_tw_holiday tw_holidays);

is is_tw_holiday(2020, 2, 28), T();
is is_tw_holiday(2020, 11, 1), F();

## By Lunar calendar
is is_tw_holiday(2020, 4, 4), T(), "Qingming in 2020.";
is is_tw_holiday(2021, 4, 5), T(), "Qingming in 2021.";

## By Lunar calendar
is is_tw_holiday(2020, 10, 1), T(), "Mid-autum festival in 2020.";

my $h2020 = tw_holidays(2020);
note $h2020;

done_testing;
