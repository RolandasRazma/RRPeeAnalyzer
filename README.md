# RRPeeAnalyzer

Ah, [healthcare](http://en.wikipedia.org/wiki/Health_care)... it was always an area of interest to me... 
I was wondering what kind of test can you do at home to continuously monitor your health and came across [Urine Test Strips](http://en.wikipedia.org/wiki/Urine_test_strip). It sounds like a straight forward test until you discover that after dipping it into your [urine](http://en.wikipedia.org/wiki/Urine) you need to sit around with a [stopwatch](http://en.wikipedia.org/wiki/Stopwatch) and check results at certain time periods.

I checked out [Amazon](http://amazon.co.uk/) for a device that would do that for me but the cheapest [Urine Analyzer](http://www.amazon.co.uk/Combi-Scan-100-Urine-Analyzer/dp/B00F377MNI/) cost a whooping £854!

So, [Urine Test Strips](http://www.amazon.co.uk/Health-Parameter-Professional-Urinalysis-Multisticks/dp/B0032IKZV6/) and [Urine Analyzer](http://www.amazon.co.uk/Combi-Scan-100-Urine-Analyzer/dp/B00F377MNI/) is £863! - way too much for my curiosity.

<img src="Images/amazon-B0032IKZV6.jpg" width="50%"><img src="Images/amazon-B00F377MNI.jpg" width="50%">

### The Software
But hey, I'm an iOS dev and surely I can write an "App For That"! I quickly prototyped iOS app using [OpenCV](http://opencv.org) where you snap photo of test strip, app finds squares and... well... it could tell your results...

<img src="Images/iOSOpenCV.jpg" width="100%">

... the only problem is - you still need to stand with a freaking stopwatch and snap at the designated times! Even if I could add a timer to the app to snap at these intervals, no way I'm standing and staring at the stip for 2 minutes waiting for the results.

### The Hardware
So I decided to rig something up from stuff laying around.

<img src="Images/iphone_box.jpg" width="100%">

At first I tried if an iPhone box height is enough for the camera to focus on things at the bottom - it wasn't - iPhone cammera needs around 10cm to focus. The solution was straight forward - to cut out the bottom of the smaller box and glue them together to double the height.

<img src="Images/cut_bottom.jpg" width="50%"><img src="Images/cut_bottom_blue.jpg" width="50%">

And if I am already making an iPhone holder, why not to fix test strip every time in more or less same place - that will simplify the app itself. I cut out a hole on the side where I will be inserting the test strip, then I cut a pen in half, and glued the two pieces to the bottom to create a base where the strip will be placed.

<img src="Images/stip_hole.jpg" width="33%"><img src="Images/pen.jpg" width="33%"><img src="Images/pen_cut_in_half.jpg" width="33%">
<img src="Images/half_pen_glue.jpg" width="33%"><img src="Images/half_glued.jpg" width="33%"><img src="Images/half_glued_strip.jpg" width="33%">
<img src="Images/black_marker.jpg" width="33%"><img src="Images/color_black.jpg" width="33%"><img src="Images/half_glued_strip_black.jpg" width="33%">

The position of the strip holder was my mistake. I didn't account that the iPhone's camera is not positioned in the middle - if I was to make another prototype I would move the strip holder to the right.
 
As for fixing the iPhone on top, I can use a piece of plastic that came in the iPhone box itself - I just need to cut out a small hole for the camera lense.

<img src="Images/cut_camera_hole.jpg" width="50%"><img src="Images/cut_camera_hole_top.jpg" width="50%">

First test using iPhone flash.

<img src="Images/first_test_x.jpg" width="50%"><img src="Images/first_test.jpg" width="50%">

Not bad but lighting is very uneven. Even if I would be able to compensate for that in software maybe I can do better.

I had backlit LED laying around so I decided to add it to check if lighting conditions will improve so I wouldn't need to use iPhone flash.

<img src="Images/backlit_led.jpg" width="50%"><img src="Images/backlit_led_mounted.jpg" width="50%">
<img src="Images/battery.jpg" width="33%"><img src="Images/battery_fix.jpg" width="33%"><img src="Images/backlit_led_mounted_top.jpg" width="33%">

Because some light was leaking from the gap above iPhone I decided to cover it up to get a more consistant lighting conditions. 
And here you go... DIY Urine Analyzer!

<img src="Images/done.jpg" width="50%"><img src="Images/done_on.jpg" width="50%">

Some testing action! (gross parts redacted).

<img src="Images/done_go.jpg" width="100%">

First test result over time (multiple shots combined in one)

<img src="Images/test1.jpg" width="100%">

Not bad, but it seems like it still lacks light. Black coloured walls absorb light so I need to make them either white or reflective. And what can be simpler than using some backing foil!

<img src="Images/foil.jpg" width="33%"><img src="Images/foil2.jpg" width="33%"><img src="Images/foil3.jpg" width="33%"><img src="Images/foil4.jpg" width="100%">

Second test result over time (multiple shots combined in one)

<img src="Images/test1.jpg" width="100%">

### The Software
So how do we go from photo of test strip to values of Leukocytes, Nitrite, Urobilinogen, Protein, pH, Blood, Specific gravity, Ketones, Bilirubin and Glucose?

<img src="Images/RRCaptureSessionStillColorCompare.jpg" width="100%">

You can find iOS application in <a href="RRPeeAnalyzer">/RRPeeAnalyzer</a>. Hopefully I will find some time to write about it and how I use [OpenCV](http://opencv.org) to find rects at some point...

to be continued...

### Samples
If for any reason you are interested in samples, you can find them at <a href="Images/Samples/">/Images/Samples/</a>. Every directory is new test, and file are named with time offset.
