package examples

import "core:fmt"
import "core:time"
import "core:time/timezone"
import "core:time/datetime"

import sft "../../strftime"
//import sft "shared:strftime"

main :: proc() {

	//	See strftime.odin for supported format options
	
	fmt.println()
{
	//  strftime by region
	//	local time based on provided region
	//	Preferred method
	fmt.println("strftime by region - local time based on provided region")
	fmt.println()

	//	Get TZ_Region once, and keep it active while continuously getting time
	//	Then, at end of the program, delete it
	tz, tz_ok := timezone.region_load("local", context.allocator)
	defer timezone.region_destroy(tz)

	buf: [128]byte
	fmt.println(sft.strftime(buf[:], "%r %Z %-z", tz) or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "%A %B %Y-%m-%d %I:%M:%S %P", tz) or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "%a %b %-m/%-d/%-y (24 Hour) %-H:%-M:%-S (12 Hour) %-I:%-M:%-S %-P", tz) or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "Timestamp in Milliseconds %FT%T.%-f%-z", tz) or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "Timestamp in Microseconds %FT%T.%f%-z", tz) or_else string(buf[:]))
}
	fmt.println()
{
	//  strftime local time
	//	automatically gets local region
	//	This will auto allocate and deallocate region on each call
	//	Handy for one-off time, but not the best if continuously getting time in a loop
	//	For regular looping to get time, recommend using strftime by region from example above
	fmt.println("strftime local time - region auto discovered")
	fmt.println()

	buf: [128]byte
	fmt.println(sft.strftime(buf[:], "%r %Z %-z") or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "%A %B %Y-%m-%d (24 Hour) %H:%M:%S (12 Hour) %I:%M:%S %P") or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "%a %b %-m/%-d/%-y (24 Hour) %-H:%-M:%-S (12 Hour) %-I:%-M:%-S %-P") or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "Timestamp in Milliseconds %FT%T.%-f%-z") or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "Timestamp in Microseconds %FT%T.%f%-z") or_else string(buf[:]))
}
	fmt.println()
{
	//	strftime by datetime
	//	Useful for getting formatted time of any DateTime from past, present or future
	//	If looking to get current time, use the strftime by region from example above
	fmt.println("strftime by datetime - get your own region and time")
	fmt.println()
  
	//	Get TZ_Region once, and keep it active while continuously getting time
	//	Then, at end of the program, delete it
	tz, tz_ok := timezone.region_load("local", context.allocator)
	defer timezone.region_destroy(tz)

	//	This example gets present time
	//	Get current time, and convert UTC from time.now() to tz time
	tm, tm_ok := time.time_to_datetime(time.now())
	dt, dt_ok := timezone.datetime_to_tz(tm, tz)
  
	buf: [128]byte
	fmt.println(sft.strftime(buf[:], "%r %Z %-z", dt) or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "%A %B %Y-%m-%d (24 Hour) %H:%M:%S (12 Hour) %I:%M:%S %P", dt) or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "%a %b %-m/%-d/%-y (24 Hour) %-H:%-M:%-S (12 Hour) %-I:%-M:%-S %-P", dt) or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "Timestamp in Milliseconds %FT%T.%-f%-z", dt) or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "Timestamp in Microseconds %FT%T.%f%-z", dt) or_else string(buf[:]))
}
	fmt.println()
{
	//  strftime by time
	//	region information not availible for formatting
	//	The time.Time type only stores date and time in a single nanosecond value
	//	No region information like UTC offset, time zone, etc.
	fmt.println("strftime by time - region information not availible for formatting")
	fmt.println()

	//	Apply an offset if you so choose, otherwise time from time.now() is UTC
	tm := time.time_add(time.now(), -5 * time.Hour)

	buf: [128]byte
	fmt.println(sft.strftime(buf[:], "%A %B %Y-%m-%d (24 Hour) %H:%M:%S (12 Hour) %I:%M:%S %P", tm) or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "%a %b %-m/%-d/%-y (24 Hour) %-H:%-M:%-S (12 Hour) %-I:%-M:%-S %-P", tm) or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "Timestamp in Milliseconds %FT%T.%-f%-z", tm) or_else string(buf[:]))
	fmt.println(sft.strftime(buf[:], "Timestamp in Microseconds %FT%T.%f%-z", tm) or_else string(buf[:]))
}
	fmt.println()
{
	//	Taking a trip around the world and printing current date/time in different formats for each
	fmt.println("Taking a trip around the world and printing current date/time in different formats for each")
	fmt.println()

	tz: [8]^datetime.TZ_Region
	ok: [8]bool

	tz[0], ok[0] = timezone.region_load("America/New_York", context.allocator)
	tz[1], ok[1] = timezone.region_load("America/Chicago", context.allocator)
	tz[2], ok[2] = timezone.region_load("America/Los_Angeles", context.allocator)
	tz[3], ok[3] = timezone.region_load("Asia/Tokyo", context.allocator)
	tz[4], ok[4] = timezone.region_load("Asia/Hong_Kong", context.allocator)
	tz[5], ok[5] = timezone.region_load("Europe/Moscow", context.allocator)
	tz[6], ok[6] = timezone.region_load("Europe/Rome", context.allocator)
	tz[7], ok[7] = timezone.region_load("Europe/London", context.allocator)

	buf: [128]byte
	for i :=0; i < 8 && ok[i]; i += 1 {
		fmt.println(sft.strftime(buf[:], "%r %Z %-z", tz[i]) or_else string(buf[:]))
		fmt.println(sft.strftime(buf[:], "%A %B %Y-%m-%d (24 Hour) %H:%M:%S (12 Hour) %I:%M:%S %P", tz[i]) or_else string(buf[:]))
		fmt.println(sft.strftime(buf[:], "%a %b %-m/%-d/%-y (24 Hour) %-H:%-M:%-S (12 Hour) %-I:%-M:%-S %-P", tz[i]) or_else string(buf[:]))
		fmt.println(sft.strftime(buf[:], "Timestamp in Milliseconds %FT%T.%-f%-z", tz[i]) or_else string(buf[:]))
		fmt.println()
	}

	for i :=0; i < 8; i += 1 {
		timezone.region_destroy(tz[i], context.allocator)
	}

}

}