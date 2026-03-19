package strftime

/*
Odin License
https://github.com/odin-lang/Odin/blob/master/LICENSE

strftime.odin License
Copyright (c) 2026 xuul @ https://github.com/OnlyXuul. All rights reserved.

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
*/

import "core:math"
import "core:time"
import "core:time/datetime"
import "core:time/timezone"

@(rodata)
weekday := [7][]byte {
	{'S','u','n','d','a','y'},
  {'M','o','n','d','a','y'},
  {'T','u','e','s','d','a','y'},
  {'W','e','d','n','e','s','d','a','y'},
  {'T','h','u','r','s','d','a','y'},
  {'F','r','i','d','a','y'},
  {'S','a','t','u','r','d','a','y'},
}

@(rodata)
month := [13][]byte {
	{},
	{'J','a','n','u','a','r','y'},
	{'F','e','b','r','u','a','r','y'},
	{'M','a','r','c','h'},
	{'A','p','r','i','l'},
	{'M','a','y'},
	{'J','u','n','e'},
	{'J','u','l','y'},
	{'A','u','g','u','s','t'},
	{'S','e','p','t','e','m','b','e','r'},
	{'O','c','t','o','b','e','r'},
	{'N','o','v','e','m','b','e','r'},
	{'D','e','c','e','m','b','e','r'},
}

@(rodata)
num := [10]byte {'0','1','2','3','4','5','6','7','8','9'}

/*
** Special **
- %%  Escapes %
- %c  Date and time representation     Sun Mar 08 14:30:00 2026
- %D  Date representation              equivalent to "%m/%d/%y"
- %F  Date representation              equivalent to "%Y-%m-%d"
- %R  Time representation              equivalent to "%H:%M"
- %s  RFC3339 Timestamp microseconds   equivalent to %FT%T.%f%-z - offset replaced with Z if not applicable
- %-s RFC3339 Timestamp milliseconds   equivalent to %FT%T.%-f%-z - offset replaced with Z if not applicable
- %T  Time representation              equivalent to "%H:%M:%S"

** Year **
- %C  2 digit century                   00-99
- %y  Year no century zero padded       00-99
- %-y Year no century not zero padded   0-99
- %Y  Year with century                 2026

** Month **
- %b  Abbreviated month                 Jan
- %B  Full month name                   January
- %m  Month zero padded                 01-12
- %-m Month not zero padded             1-12

** Week **
- %U  week of the year zero padded      00-53 Sunday is 1st day of week
- %-U week of the year not zero padded  0-53 Sunday is 1st day of week
- %W  week of the year zero padded      00-53 Monday is 1st day of week
- %-W week of the year not zero padded  0-53 Monday is 1st day of week

** Day **
- %a  Abbreviated weekday               Sun
- %A  Full weekday name                 Sunday
- %d  Day of month zero padded          01-31
- %-d Day of month not zero padded      1-31
- %j  day of the year zero padded       000-366
- %-j day of the year not zero padded   0-366
- %u  Weekday as a decimal number       1-7 - Monday = 1
- %w  Weekday as a decimal number       0-6 - Sunday = 0

** Time **
- %H  Hour (24-hour) zero padded        00-23
- %-H Hour (24-hour) not zero padded    0-23
- %I  Hour (12-hour) zero padded        01-12
- %-I Hour (12-hour) not zero padded    1-12
- %M  Minute zero padded                00-59
- %-M Minute not zero padded            0-59
- %p  AM or PM marker                   am, pm
- %-p AM or PM marker                   a.m., p.m.
- %P  AM or PM marker                   AM, PM
- %-P  AM or PM marker                  A.M., P.M.
- %S  Seconds zero padded               00-59
- %-S Seconds not zero padded           0-59
- %f  Microseconds zero padded          000000 - 999999
- %-f Milliseconds zero padded          000 - 999

** Zone **
- %z  UTC offset                        +HHMM or -HHMM
- %-z UTC offset                        +HH:MM or -HH:MM
- %Z  Time zone                         CST
- %r  Region                            America/Chicago

Referenced from:
- https://en.cppreference.com/w/c/chrono/strftime
- https://strftime.org/
*/
strftime :: proc {strftime_time, strftime_datetime, strftime_local, strftime_region}

/*
- Format current time for the provided datetime.TZ_Region
- Load the datetime.TZ_Region once at beginning of program
- Destroy it at end so that it is not constantly allocating/deallocating

Example:

	tz, tz_ok := timezone.region_load("local", context.allocator)
	defer timezone.region_destroy(tz)

	buf: [64]byte
	tm, tm_ok := sft.strftime(buf[:], "%A %B %Y-%m-%d %I:%M:%S %P", tz)
	fmt.println(tm)

*/
strftime_region :: proc(buf: []byte, format: string, tz: ^datetime.TZ_Region) -> (time_string: string, ok: bool) {
	now := time.time_to_datetime(time.now()) or_return
	dt  := timezone.datetime_to_tz(now, tz) or_return
	return strftime_datetime(buf[:], format, dt)
}

/*
- Format current local time - allocates and deallocates region on each call
- For regular looping, recommend using strftime_region, strftime_time, or strftime_datetime instead
- This is best for only quick one-off aquiring of time and not efficient for looping

Example:

	buf: [64]byte
	tm, tm_ok := sft.strftime(buf[:], "%A %B %Y-%m-%d %I:%M:%S %P")
	fmt.println(tm)

*/
strftime_local :: proc(buf: []byte, format: string) -> (time_string: string, ok: bool) { 
	tz := timezone.region_load("local", context.allocator) or_return
	defer timezone.region_destroy(tz, context.allocator)
	tm := time.time_to_datetime(time.now()) or_return
	dt := timezone.datetime_to_tz(tm, tz) or_return
	return strftime_datetime(buf[:], format, dt)
}

/*
- Format specified time.Time
- Region formatting will be ignored since time.Time does not contain utc offset, time zone, etc.
- Example gets UTC time and applies an offset

Example:

	buf: [64]byte
	now := time.time_add(time.now(), -5 * time.Hour)
	tm, tm_ok := sft.strftime(buf[:], "%A %B %Y-%m-%d %I:%M:%S %P", now)
	fmt.println(tm)

*/
strftime_time :: proc(buf: []byte, format: string, t: time.Time) -> (time_string: string, ok: bool) {
	dt := time.time_to_datetime(t) or_return
	return strftime_datetime(buf[:], format, dt)
}

/*
- Format specified datetime.DateTime
- Region formatting supported if included in the supplied datetime.DateTime
- Can be used to format past, present, future time
- Example gets present time

Example:

	tz, tz_ok := timezone.region_load("local", context.allocator)
	defer timezone.region_destroy(tz)

	tm, tm_ok := time.time_to_datetime(time.now())
	dt, dt_ok := timezone.datetime_to_tz(tm, tz)

	buf: [64]byte
	ts, ts_ok := sft.strftime(buf[:], "%A %B %Y-%m-%d %I:%M:%S %P", dt)
	fmt.println(ts)

*/
strftime_datetime :: proc(buf: []byte, format: string, dt: datetime.DateTime) -> (time_string: string, ok: bool) {
	//	Internal buffer manager
	add_to_buf :: proc(buf: []byte, new: []byte, idx: int, max: int) -> (next_idx: int, ok: bool) {
		for n, i in new {
			if idx + i >= max { return } // full - not ok
			buf[idx + i] = n
			next_idx = idx+i+1 >= max ? max : idx+i+1
		}
		return next_idx, true
	}

	//	Internal string to bytes shortcut
	tobytes :: proc(s: string) -> []byte {	return transmute([]byte)(s) }

	//	Validate
	if datetime.validate_datetime(dt) != nil { return }
	ord, ord_err := datetime.date_to_ordinal(dt)
	if ord_err != nil { return }

	idx: int
	max := len(buf)
	format_length := len(format)

	for i := 0; i < format_length; i += 1 {
		
		// format options that **do not** have '-' (i.e. %-d)
		if format[i] == '%' && i+1 <= format_length {
			switch format[i+1] {
			//	** Special **
			case '%': i += 1 // escape percent
				idx = add_to_buf(buf, {'%'}, idx, max) or_return
			case 'c': i += 1 // Date and time representation - Sun Mar 08 14:30:00 2026
				thisbuf: [24]byte
				_ = strftime(thisbuf[:], "%a %b %d %H:%M:%S %Y", dt) or_return
				idx = add_to_buf(buf, thisbuf[:], idx, max) or_return
			case 'D': i += 1 // equivalent to "%m/%d/%y"
				thisbuf: [8]byte
				_ = strftime(thisbuf[:], "%m/%d/%y", dt) or_return
				idx = add_to_buf(buf, thisbuf[:], idx, max) or_return
			case 'F': i += 1 // equivalent to "%Y-%m-%d"
				thisbuf: [10]byte
				_ = strftime(thisbuf[:], "%Y-%m-%d", dt) or_return
				idx = add_to_buf(buf, thisbuf[:], idx, max) or_return
			case 'R': i += 1 // equivalent to "%H:%M"
				thisbuf: [6]byte
				_ = strftime(thisbuf[:], "%H:%M", dt) or_return
				idx = add_to_buf(buf, thisbuf[:], idx, max) or_return
			case 's': i += 1
				if dt.tz != nil {
					thisbuf: [32]byte
					_ = strftime(thisbuf[:], "%FT%T.%f%-z", dt) or_return
					idx = add_to_buf(buf, thisbuf[:], idx, max) or_return
				} else {
					thisbuf: [27]byte
					_ = strftime(thisbuf[:], "%FT%T.%fZ", dt) or_return
					idx = add_to_buf(buf, thisbuf[:], idx, max) or_return
				}
			case 'T': i += 1 // equivalent to "%H:%M:%S"
				thisbuf: [8]byte
				_ = strftime(thisbuf[:], "%H:%M:%S", dt) or_return
				idx = add_to_buf(buf, thisbuf[:], idx, max) or_return
			//	** Year **
			case 'C': i += 1
				idx = add_to_buf(buf, {num[dt.year/1000], num[(dt.year%1000)/100]}, idx, max) or_return
			case 'y': i += 1
				idx = add_to_buf(buf, {num[(dt.year%100)/10], num[dt.year%10]}, idx, max) or_return
			case 'Y': i += 1
				idx = add_to_buf(buf, {num[dt.year/1000], num[(dt.year%1000)/100], num[(dt.year%100)/10], num[dt.year%10]}, idx, max) or_return
			//	** Month **
			case 'b': i += 1
				idx = add_to_buf(buf, month[dt.month][:3], idx, max) or_return
			case 'B': i += 1
				idx = add_to_buf(buf, month[dt.month], idx, max) or_return
			case 'm': i += 1
				idx = add_to_buf(buf, {num[dt.month/10], num[dt.month%10]}, idx, max) or_return
			//	** Week **
			case 'U': i += 1
				if new_year, ny_err := datetime.components_to_ordinal(dt.year, 1, 1); ny_err == nil {
					first_day := new_year %% 7
					if today, td_err := datetime.day_number(dt); td_err == nil {
						week := first_day < 5 ? int(math.ceil(f16(today)/7)) : int(math.ceil(f16(today)/7)) + 1
						idx = add_to_buf(buf, {num[week/10], num[week%10]}, idx, max) or_return		
					}
				}
			case 'W': i += 1
				if new_year, ny_err := datetime.components_to_ordinal(dt.year, 1, 1); ny_err == nil {
					first_day := new_year %% 7
					if today, td_err := datetime.day_number(dt); td_err == nil {
						week := first_day < 4 ? int(math.ceil(f16(today)/7)) : int(math.ceil(f16(today)/7)) + 1
						idx = add_to_buf(buf, {num[week/10], num[week%10]}, idx, max) or_return		
					}
				}
			//	** Day **
			case 'a': i += 1
				idx = add_to_buf(buf, weekday[ord %% 7][:3], idx, max) or_return
			case 'A': i += 1
				idx = add_to_buf(buf, weekday[ord %% 7], idx, max) or_return
			case 'd': i += 1
				idx = add_to_buf(buf, {num[dt.day/10], num[dt.day%10]}, idx, max) or_return
			case 'j': i += 1
				day, err := datetime.day_number(dt)
				if err == nil {
					idx = add_to_buf(buf, {num[day/100], num[(day%100)/10], num[day%10]}, idx, max) or_return
				}
			case 'u': i += 1
				day := ord %% 7
				idx = add_to_buf(buf, day == 0 ? {num[7]} : {num[day]}, idx, max) or_return
			case 'w': i += 1
				idx = add_to_buf(buf, {num[ord %% 7]}, idx, max) or_return
			//	** Time **
			case 'H': i += 1
				idx = add_to_buf(buf, {num[dt.hour/10], num[dt.hour%10]}, idx, max) or_return
			case 'I': i += 1
				hour12 := dt.hour == 0 ? 12 : dt.hour
				hour12 = hour12 > 12 ? hour12 - 12 : hour12
				idx = add_to_buf(buf, {num[hour12/10], num[hour12%10]}, idx, max) or_return
			case 'M': i += 1
				idx = add_to_buf(buf, {num[dt.minute/10], num[dt.minute%10]}, idx, max) or_return
			case 'S': i += 1
				idx = add_to_buf(buf, {num[dt.second/10], num[dt.second%10]}, idx, max) or_return
			case 'f': i += 1
				m := dt.nano/1000
				micro := []byte {
					num[(m/100000)], num[(m%100000)/10000], num[(m%10000)/1000],
					num[(m%1000)/100],	num[(m%100)/10], num[(m%10)],
				}
				idx = add_to_buf(buf, micro, idx, max) or_return
			case 'p': i += 1
				idx = add_to_buf(buf, dt.hour < 12 ? {'a', 'm'} : {'p', 'm'}, idx, max) or_return
			case 'P': i += 1
				idx = add_to_buf(buf, dt.hour < 12 ? {'A', 'M'} : {'P', 'M'}, idx, max) or_return
			//	** Zone **
			case 'Z': i += 1
				if dt.tz != nil {
					idx = add_to_buf(buf, timezone.dst(dt) ? tobytes(dt.tz.rrule.dst_name) : tobytes(dt.tz.rrule.std_name), idx, max) or_return
				}
			case 'z': i += 1
				if dt.tz != nil {
					offset := timezone.dst(dt) ? dt.tz.rrule.dst_offset : dt.tz.rrule.std_offset
					sign : byte = offset < 0 ? '-' : '+'
					offset_hour := abs(offset / 60 / 60)
					offset_min  := abs((offset / 60) % 60)
					idx = add_to_buf(buf, {sign, num[offset_hour/10], num[offset_hour%10], num[offset_min/10], num[offset_min%10]}, idx, max) or_return
				}
			case 'r': i += 1
				if dt.tz != nil {
					idx = add_to_buf(buf, tobytes(dt.tz.name), idx, max) or_return
				}
			}

			// format options that have '-' (i.e. %-d)
			if format[i] == '%' && i+2 <= format_length && format[i+1] == '-' {
				switch format[i+2] {
				//	** Special **
				case 's': i += 2
					if dt.tz != nil {
						thisbuf: [32]byte
						_ = strftime(thisbuf[:], "%FT%T.%-f%-z", dt) or_return
						idx = add_to_buf(buf, thisbuf[:], idx, max) or_return
					} else {
						thisbuf: [27]byte
						_ = strftime(thisbuf[:], "%FT%T.%-fZ", dt) or_return
						idx = add_to_buf(buf, thisbuf[:], idx, max) or_return
					}
				//	** Year **
				case 'y': i += 2
					year := dt.year%100
					if year < 10 {
						idx = add_to_buf(buf, {num[year%10]}, idx, max) or_return
					} else {
						idx = add_to_buf(buf, {num[year/10], num[year%10]}, idx, max) or_return
					}
				//	** Month **
				case 'm': i += 2
					if dt.month < 10 {
						idx = add_to_buf(buf, {num[dt.month%10]}, idx, max) or_return
					} else {
						idx = add_to_buf(buf, {num[dt.month/10], num[dt.month%10]}, idx, max) or_return
					}
				//	** Week **
				case 'U': i += 2
				if new_year, ny_err := datetime.components_to_ordinal(dt.year, 1, 1); ny_err == nil {
					first_day := new_year %% 7
					if today, td_err := datetime.day_number(dt); td_err == nil {
						week := first_day < 5 ? int(math.ceil(f16(today)/7)) : int(math.ceil(f16(today)/7)) + 1
						if week < 10 {
							idx = add_to_buf(buf, {num[week%10]}, idx, max) or_return		
						} else {
							idx = add_to_buf(buf, {num[week/10], num[week%10]}, idx, max) or_return		
						}
					}
				}
			case 'W': i += 2
				if new_year, ny_err := datetime.components_to_ordinal(dt.year, 1, 1); ny_err == nil {
					first_day := new_year %% 7
					if today, td_err := datetime.day_number(dt); td_err == nil {
						week := first_day < 4 ? int(math.ceil(f16(today)/7)) : int(math.ceil(f16(today)/7)) + 1
						if week < 10 {
							idx = add_to_buf(buf, {num[week%10]}, idx, max) or_return		
						} else {
							idx = add_to_buf(buf, {num[week/10], num[week%10]}, idx, max) or_return		
						}
					}
				}
				//	** Day **
				case 'd': i += 2
					if dt.day < 10 {
						idx = add_to_buf(buf, {num[dt.day%10]}, idx, max) or_return
					} else {
						idx = add_to_buf(buf, {num[dt.day/10], num[dt.day%10]}, idx, max) or_return
					}
				case 'j': i += 2
					day, err := datetime.day_number(dt)
					if err == nil {
						if day < 10 {
							idx = add_to_buf(buf, {num[day%10]}, idx, max) or_return
						} else if day < 100 {
							idx = add_to_buf(buf, {num[(day%100)/10], num[day%10]}, idx, max) or_return
						} else {
							idx = add_to_buf(buf, {num[day/100], num[(day%100)/10], num[day%10]}, idx, max) or_return	
						}
					}
				//	** Time **
				case 'H': i += 2
					if dt.hour < 10 {
						idx = add_to_buf(buf, {num[dt.hour%10]}, idx, max) or_return
					} else {
						idx = add_to_buf(buf, {num[dt.hour/10], num[dt.hour%10]}, idx, max) or_return
					}
				case 'I': i += 2
					hour12 := dt.hour == 0 ? 12 : dt.hour
					hour12 = hour12 > 12 ? hour12 - 12 : hour12
					if hour12 < 10 {
							idx = add_to_buf(buf, {num[hour12%10]}, idx, max) or_return
					} else {
							idx = add_to_buf(buf, {num[hour12/10], num[hour12%10]}, idx, max) or_return
					}
				case 'M': i += 2
					if dt.minute < 10 {
						idx = add_to_buf(buf, {num[dt.minute%10]}, idx, max) or_return
					} else {
						idx = add_to_buf(buf, {num[dt.minute/10], num[dt.minute%10]}, idx, max) or_return
					}
				case 'S': i += 2
					if dt.second < 10 {
						idx = add_to_buf(buf, {num[dt.second%10]}, idx, max) or_return
					} else {
						idx = add_to_buf(buf, {num[dt.second/10], num[dt.second%10]}, idx, max) or_return
					}
				case 'f': i += 2
					m := dt.nano/1_000_000
					milli := []byte {
						num[m/100],	num[(m%100)/10], num[(m%10)],
					}
					idx = add_to_buf(buf, milli, idx, max) or_return
				case 'p': i += 2
					idx = add_to_buf(buf, dt.hour < 12 ? {'a', '.','m', '.'} : {'p', '.', 'm', '.'}, idx, max) or_return
				case 'P': i += 2
					idx = add_to_buf(buf, dt.hour < 12 ? {'A', '.', 'M', '.'} : {'P', '.', 'M', '.'}, idx, max) or_return
				//	** Zone **
				case 'z': i += 2
					if dt.tz != nil {
						offset := timezone.dst(dt) ? dt.tz.rrule.dst_offset : dt.tz.rrule.std_offset
						sign : byte = offset < 0 ? '-' : '+'
						offset_hour := abs(offset / 60 / 60)
						offset_min  := abs((offset / 60) % 60)
						idx = add_to_buf(buf, {sign, num[offset_hour/10], num[offset_hour%10], ':', num[offset_min/10], num[offset_min%10]}, idx, max) or_return
					}
				}
			}
		} else {
			idx = add_to_buf(buf, {format[i]}, idx, max) or_return
		}
	}
	return (string(buf[:idx])), true
}