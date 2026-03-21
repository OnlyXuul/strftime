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
	fmt.println(sft.strftime(buf[:], "%r %Z %-z", tz))
	fmt.println(sft.strftime(buf[:], "%A %B %Y-%m-%d %I:%M:%S %P", tz))
	fmt.println(sft.strftime(buf[:], "%a %b %-m/%-d/%-y (24 Hour) %-H:%-M:%-S (12 Hour) %-I:%-M:%-S %-P", tz))
	fmt.println(sft.strftime(buf[:], "Timestamp in Milliseconds %FT%T.%-f%-z", tz))
	fmt.println(sft.strftime(buf[:], "Timestamp in Microseconds %FT%T.%f%-z", tz))
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
	fmt.println(sft.strftime(buf[:], "%r %Z %-z"))
	fmt.println(sft.strftime(buf[:], "%A %B %Y-%m-%d (24 Hour) %H:%M:%S (12 Hour) %I:%M:%S %P"))
	fmt.println(sft.strftime(buf[:], "%a %b %-m/%-d/%-y (24 Hour) %-H:%-M:%-S (12 Hour) %-I:%-M:%-S %-P"))
	fmt.println(sft.strftime(buf[:], "Timestamp in Milliseconds %FT%T.%-f%-z"))
	fmt.println(sft.strftime(buf[:], "Timestamp in Microseconds %FT%T.%f%-z"))
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
	fmt.println(sft.strftime(buf[:], "%r %Z %-z", dt))
	fmt.println(sft.strftime(buf[:], "%A %B %Y-%m-%d (24 Hour) %H:%M:%S (12 Hour) %I:%M:%S %P", dt))
	fmt.println(sft.strftime(buf[:], "%a %b %-m/%-d/%-y (24 Hour) %-H:%-M:%-S (12 Hour) %-I:%-M:%-S %-P", dt))
	fmt.println(sft.strftime(buf[:], "Timestamp in Milliseconds %FT%T.%-f%-z", dt))
	fmt.println(sft.strftime(buf[:], "Timestamp in Microseconds %FT%T.%f%-z", dt))
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
	fmt.println(sft.strftime(buf[:], "%A %B %Y-%m-%d (24 Hour) %H:%M:%S (12 Hour) %I:%M:%S %P", tm))
	fmt.println(sft.strftime(buf[:], "%a %b %-m/%-d/%-y (24 Hour) %-H:%-M:%-S (12 Hour) %-I:%-M:%-S %-P", tm))
	fmt.println(sft.strftime(buf[:], "Timestamp in Milliseconds %FT%T.%-f%-z", tm))
	fmt.println(sft.strftime(buf[:], "Timestamp in Microseconds %FT%T.%f%-z", tm))
}
	fmt.println()
{
	//	Taking a trip around the world
	fmt.println("Taking a trip around the world")
	fmt.println()

	region := []string {
		"Pacific/Fiji",
		"Asia/Magadan",
		"Australia/Melbourne",
		"Asia/Tokyo",
		"Asia/Singapore",
		"Asia/Bangkok",
		"Asia/Dhaka",
		"Asia/Karachi",
		"Asia/Dubai",
		"Europe/Moscow",
		"Europe/Kyiv",
		"Europe/Rome",
		"Europe/London",
		"Atlantic/Azores",
		"Atlantic/South_Georgia",
		"America/Montevideo",
		"America/Santiago",
		"America/New_York",
		"America/Chicago",
		"America/Denver",
		"America/Los_Angeles",
		"Pacific/Honolulu",
		"Pacific/Samoa",
	}

	for r in region {
		if tz, ok := timezone.region_load(r); ok {
			buf: [64]byte
			fmt.printf("%-22s", sft.strftime(buf[:], "%r",  tz))
			fmt.printf("%5s ", sft.strftime(buf[:], "%Z",  tz))
			fmt.println(sft.strftime(buf[:], "%-z %F %I:%M:%S %P",  tz))
			timezone.region_destroy(tz)
		}
	}
	fmt.println()
}

}