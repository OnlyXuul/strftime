# strftime for Odin

## Expected Behavior
1. First and foremost: Error state is defined and not undefined as is the case with C versions of strftime. This version of strftime should never crash a program if time formatting fails. If it does, it is conciderred a bug. Please report these bugs as priority.
2. General error: An empty string is returned with boolean of false.
3. Buffer over-run error: An empty string is returned with boolean of false. The contents of the provided buffer will still contain all data written to the buffer up until the point the buffer max was reached.
4. On success: a string slice view of provided buffer up to the last index written to and boolean true. i.e. The returned string length only reflects the data written to the buffer and not the entire buffer length.
5. The buffer is not zeroed by strftime, and may contain more data from subsequent re-uses beyond the last index the returned string slice is using.
6. Region format specifiers, like UTC Offset, timezone, etc, will be quietly ignored if not availible.
7. Timestamp specifiers will always return a string of the same length, respectively. Exceptions: In the case of %s and %-s, offset is replaced with Z if not applicable. In the case of %z or %-z, offset is quietly ignored if not availible.

## Steps Linux
1. Clone strftime into odin/shared folder:
   ```bash
   cd $(odin root)shared
   git clone https://github.com/OnlyXuul/strftime.git
   ```
2. To run usage examples:
   ```bash
   cd $(odin root)shared/strftime/examples
   odin run .
   ```
## Steps Windows Powershell
1. Clone strftime into odin/shared folder:
   ```bash
   cd $(odin root)
   cd shared
   git clone https://github.com/OnlyXuul/strftime.git
   ```
2. To run usage examples:
   ```bash
   cd $(odin root)
   cd shared\strftime\examples
   odin run .
   ```
To use the library, add to the top of your project file:
   ```odin
   import sft "shared:strftime"
   ```
## Supported Format Specifiers
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
