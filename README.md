# RRPeeAnalyzer

Ah, [healthcare](http://en.wikipedia.org/wiki/Health_care)... it was always area of interest to me... 
I was wondering what kindof test you can do at home to continuously monitor your health and came around [Urine Test Strips](http://en.wikipedia.org/wiki/Urine_test_strip). That sounds like straight forward test untill you discover that after you dip it into your [urine](http://en.wikipedia.org/wiki/Urine) you need to sit around with [stopwatch](http://en.wikipedia.org/wiki/Stopwatch) and check results at certain time periods.

I checked [Amazon](http://amazon.co.uk/) for device that would do that for me but cheapest [Urine Analyzer](http://www.amazon.co.uk/Combi-Scan-100-Urine-Analyzer/dp/B00F377MNI/) cost whooping £854!

So, [Urine Test Strips](http://www.amazon.co.uk/Health-Parameter-Professional-Urinalysis-Multisticks/dp/B0032IKZV6/) and [Urine Analyzer](http://www.amazon.co.uk/Combi-Scan-100-Urine-Analyzer/dp/B00F377MNI/) is £863! - way too much for my curriosity.

<img src="Images/amazon-B0032IKZV6.jpg" width="50%"><img src="Images/amazon-B00F377MNI.jpg" width="50%">

### The Software
But hey, I'm iOS dev and surely I can write "App For That"! I quickly prototyped iOS app using [OpenCV](http://opencv.org). You snap photo of test strip, app finds squares and... well... it could tell you results...

<img src="Images/iOSOpenCV.jpg" width="100%">

... the only problem is - you still need to stand with freaking stopwatch and snap at correct times! Even if I could add timer to app to snap at correct times, no way I'm standing for 2 minutes waiting to see reluts.

### The Hardware
So I decided to rig something up from stuff I have laying around.

<img src="Images/iphone_box.jpg" width="100%">

At first I tried if iPhone box height is enaugh for camera to focus on things that are on bottom, but discovvered that not gonna work. The solution was straigh forward - cut out bottom of smaller box and glue them together to increase height.

<img src="Images/cut_bottom.jpg" width="50%"><img src="Images/cut_bottom_blue.jpg" width="50%">

If we already making iPhone holder, why not to fix test strip every time in more or less same place - that will simplify app itself. Add hole at the end where you will be inserting test strip, cut pen in half, and glue it to the bottom where you want your strip to be.

<img src="Images/stip_hole.jpg" width="33%"><img src="Images/pen.jpg" width="33%"><img src="Images/pen_cut_in_half.jpg" width="33%">
<img src="Images/half_pen_glue.jpg" width="33%"><img src="Images/half_glued.jpg" width="33%"><img src="Images/half_glued_strip.jpg" width="33%">
<img src="Images/black_marker.jpg" width="33%"><img src="Images/color_black.jpg" width="33%"><img src="Images/half_glued_strip_black.jpg" width="33%">

Position of "rail" was my first mistake. I didn't accounted that iPhone camera not in center of the phone - if I will do another prototype I will move rail to the right.
 
Lets fix iPhone on top next. For that you can use peace of plastic that came in the iPhone box itself - you just need small hole where the cammera is.

<img src="Images/cut_camera_hole.jpg" width="50%"><img src="Images/cut_camera_hole_top.jpg" width="50%">

First test using iPhones flash.

<img src="Images/first_test_x.jpg" width="50%"><img src="Images/first_test.jpg" width="50%">

Not bad but lighting is very uneven. Even if I would be able to compensate for that in software maybe I can do better.

I had backlit LED laying around so decided to add it to check if lighting conditions will improove so I wouldn't need to use iPhone flash.

<img src="Images/backlit_led.jpg" width="50%"><img src="Images/backlit_led_mounted.jpg" width="50%">
<img src="Images/battery.jpg" width="30%"><img src="Images/battery_fix.jpg" width="30%"><img src="Images/backlit_led_mounted_top.jpg" width="30%">

Because some light was leaking from gap above iphone I decided to cover it up also to get more even lighting. 
And here you go... DIY Urine Analyzer!

<img src="Images/done.jpg" width="50%"><img src="Images/done_on.jpg" width="50%">

Some testing action! (grose parts redacted).

<img src="Images/done_go.jpg" width="100%">

First test result over time (multiple shots combined in one)

<img src="Images/test1.jpg" width="100%">

not bad, but it feals like it still lacks some light. Black colored walls absorb light so we need to make them either white or reflective. And what can be simplier than using some backing foil!

<img src="Images/foil.jpg" width="33%"><img src="Images/foil2.jpg" width="33%"><img src="Images/foil3.jpg" width="33%">

### The Software
to be continued...

