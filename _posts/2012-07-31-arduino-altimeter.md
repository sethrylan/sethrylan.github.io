---
layout: post
title: Arduino Barometric Altimeter
---

# {{ page.title }}
---------------------------------------

Using Sparkfun's BMP085 sensor board ([SEN-09694](https://www.sparkfun.com/products/9694)), I put together some quick Arduino code to measure temperature-adjusted barometric pressure, store the data on an SD card using Adafruit's data logger shield ([v1.0](https://www.adafruit.com/products/243)), and then calculate altitude. This is a pretty simple project. In fact, the biggest challenge was getting a suitable formula for calculating altitude from atmospheric pressure.


Testing the sensor was very simple, following the [tutorial](http://www.sparkfun.com/tutorials/253) and [schematic](http://www.sparkfun.com/tutorial/Barometric/Example1-sch.PNG) on Sparkfun's site with breadboard wiring.

<p align="center">
  <a class="fancybox" href="/images/2012-07/photo-1-e1343336399105-300x300.jpg"><img src="/images/2012-07/photo-1-e1343336399105-300x300.jpg" align="center" width="80%"/></a>
</p>

Now adding the sensor to the data logging shield. Don't forget which pins are which, because those will be facing the PCB.

<p align="center">
  <a class="fancybox" href="/images/2012-07/photo-3-e1343336344244-300x300.jpg"><img src="/images/2012-07/photo-3-e1343336344244-300x300.jpg" align="center" width="40%"/></a>
</p>

And from the other side, where you can see the SDA, SCL, VCC and ground wires connect. Because we are using i2c for the bmp085 readings, the clock data from the data logging shield isn't available without some modifications. We are capturing milliseconds after start, so it's not very necessary.

<p align="center">
  <a class="fancybox" href="/images/2012-07/photo-4-e1343336322226-300x300.jpg"><img src="/images/2012-07/photo-4-e1343336322226-300x300.jpg" align="center" width="40%"/></a>
</p>

After connecting to a 4XAA (6VDC) battery source, we can mount this to the Easy Star as seen in the [build tutorial](../../../2012/07/17/multiplex-easy-star-build.html).

Once you have your data, you need to convert your adjusted pressure readings into altitude. The bmp085 gives you Pascals; after converting to millibar (or hPa) one can use the equation

<div>
\[
h_{alt}=\left( 1 - \left( \dfrac {p_{sta}} {p_{sealevel}}\right) ^{0.190284}\right) \times 145366.45
\]
</div>

where:
* p<sub>sta</sub> = measured pressure in millibar (or hPa)
* p<sub>sealevel</sub> = millibar (or hPa) pressure at sea level, or approximately 1013.25. In this example, I use what I know is the pressure at sea level at time=0.

This is a more accurate version of the common heuristic that pressure reduces by 1 millibar per 30ft of elevation. After this crunching we get the graph below, showing that we reached 500m in just under 3 minutes, and you can see what this looks like from the [flight video](http://youtu.be/5M-c3BhNPWc).


<p align="center">
  <a class="fancybox" href="/images/2012-07/Screenshot-from-2012-07-30-204153.png"><img src="/images/2012-07/Screenshot-from-2012-07-30-204153.png" align="center" width="80%"/></a>
</p>

<script type="text/javascript"
    src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

## Arduino Code ##
	
<iframe style="height: 600px; width: 150%; margin: 0px 0 0px;" allowTransparency="true" src="http://codebender.cc/embed/sketch:12085" frameborder="0"> </iframe>

