---
layout: post
title: Arduino Multimeter
---

# {{ page.title }}
---------------------------------------

Using Sparkfun's BMP085 sensor board ([SEN-09694](https://www.sparkfun.com/products/9694)), I put together some quick Arduino code to measure temperature-adjusted barometric pressure, store the data on an SD card using Adafruit's data logger shield ([v1.0](https://www.adafruit.com/products/243)), and then calculate altitude. This is a pretty simple project; in fact, the most difficult issue was finding a suitable formula for calculating altitude from atmospheric pressure.


Testing the sensor was very simple, following the [tutorial](http://www.sparkfun.com/tutorials/253) and [schematic](http://www.sparkfun.com/tutorial/Barometric/Example1-sch.PNG) on Sparkfun's site.

<p align="center">
  <img src="/images/2012-07/photo-1-e1343336399105-300x300.jpg" align="center" width="40%"/>
</p>

Now adding to the data logging shield. Don't forget which pins are which, because those will be facing the PCB.

<p align="center">
  <img src="/images/2012-07/photo-3-e1343336344244-300x300.jpg" align="center" width="40%"/>
</p>

And from the other side, where you can see the SDA, SCL, VCC and ground wires connect. Because we are using i2c for the bmp085 readings, the clock data from the data logging shield isn't available without some modifications. We are capturing milliseconds after start, so it's not very necessary.

<p align="center">
  <img src="/images/2012-07/photo-4-e1343336322226-300x300.jpg" align="center" width="40%"/>
</p>

After connecting to a 4XAA (6VDC) battery source, we can mount this to the Easy Star as seen in the [build tutorial](../2012/07/17/multiplex-easy-star-build.html).

Once you have your data, you need to convert your adjusted pressure readings into altitude. The bmp085 gives you Pascals; after converting to millibar (or hPa) one can use the equation

<div>
\[
h_{alt}=\left( 1 - \left( \dfrac {p_{sta}} {p_{sealevel}}\right) ^{0.190284}\right) \times 145366.45
\]
</div>

where:
* p<sub>sta</sub> = measured pressure in x1 (or hPa)
* p<sub>sealevel</sub> = millibar (or hPa) pressure at sea level; usually 1013.25, in this example, I use what I know is the pressure at sea level.

This is a more accurate version of the common heuristic that pressure reduces by 1 millibar per 30ft of elevation. After this crunching we get the graph below, showing that we reached 500m in just under 3 minutes, and you can see what this looks like from the [flight video](http://youtu.be/5M-c3BhNPWc).

<p align="center">
  <img src="/images/2012-07/Screenshot-from-2012-07-30-204153.png" align="center" width="80%"/>
</p>

    
    /* BMP085 + Data Logger
     by: Seth Rylan Gainey
     date: 2012/07/08
     license: http://sethrylan.mit-license.org/
     
     Get pressure and temperature from the BMP085 and calculate altitude.
     Serial.print it out at 9600 baud to serial monitor.
     
    "If you're using an Arduino Pro 3.3V/8MHz, or the like, you may need to 
     increase some of the delays in the bmp085ReadUP and 
     bmp085ReadUT functions."
     
     http://www.sparkfun.com/tutorial/Barometric/BMP085_Example_Code.pde
     http://www.sparkfun.com/tutorials/253
     http://www.ladyada.net/make/logshield/lighttemp.html
     https://raw.github.com/adafruit/Light-and-Temp-logger/master/lighttemplogger.pde
     */
    
    #include <Wire.h>
    #include <SD.h>
    #include "RTClib.h"
    
    #define LOG_INTERVAL  1000 // mills between entries (reduce to take more/faster data)
    #define SYNC_INTERVAL 1000 // mills between calls to flush() - to write data to the card; set to LOG_INTERVAL to write each time    
    #define ECHO_TO_SERIAL   1 // echo data to serial port
    #define WAIT_TO_START    0 // Wait for serial input in setup()
    
    // the digital pins that connect to the LEDs
    #define redLEDpin 2
    #define greenLEDpin 3
    #define BMP085_ADDRESS 0x77  // I2C address of BMP085
	
    // The analog pins that connect to the sensors
    //#define photocellPin 0           // analog 0
    //#define tempPin 1                // analog 1
    #define BANDGAPREF 14            // special indicator that we want to measure the bandgap+
    #define bandgap_voltage 1.1      // this is not super guaranteed but its not -too- off
    
    RTC_DS1307 RTC; // define the Real Time Clock object
    
    File logfile;				  // the logging file
    const unsigned char OSS = 0;  // Oversampling Setting
    const int chipSelect = 10;    // for the data logging shield, we use digital pin 10 for the SD cs line
    uint32_t syncTime = 0; // time of last sync()

    // Calibration values
    int ac1;
    int ac2; 
    int ac3; 
    unsigned int ac4;
    unsigned int ac5;
    unsigned int ac6;
    int b1; 
    int b2;
    int mb;
    int mc;
    int md;
    
    // b5 is calculated in bmp085GetTemperature(...), this variable is also used in bmp085GetPressure(...)
    // so ...Temperature(...) must be called before ...Pressure(...).
    long b5; 
    
    short temperature;
    long pressure;
    
    void error(char *str) {
      Serial.print("error: ");
      Serial.println(str);
      
      // red LED indicates error
      digitalWrite(redLEDpin, HIGH);
    
      while(1);
    }
    
    void setup() {
      Serial.begin(9600);
      
      // use debugging LEDs
      pinMode(redLEDpin, OUTPUT);
      pinMode(greenLEDpin, OUTPUT);
      
    #if WAIT_TO_START
      Serial.println("Type any character to start");
      while (!Serial.available());
    #endif //WAIT_TO_START
      
      // initialize the SD card
      Serial.print("Initializing SD card...");
      // make sure that the default chip select pin is set to
      // output, even if you don't use it:
      pinMode(10, OUTPUT);
      
      // see if the card is present and can be initialized:
      if (!SD.begin(chipSelect)) {
        error("Card failed, or not present");
      }
      Serial.println("card initialized.");
      
      // create a new file
      char filename[] = "LOGGER00.CSV";
      for (uint8_t i = 0; i < 100; i++) {
        filename[6] = i/10 + '0';
        filename[7] = i%10 + '0';
        if (! SD.exists(filename)) {
          // only open a new file if it doesn't exist
          logfile = SD.open(filename, FILE_WRITE); 
          break;  // leave the loop!
        }
      }
      
      if (! logfile) {
        error("couldnt create file");
      }
      
      Serial.print("Logging to: ");
      Serial.println(filename);
      
      // connect to RTC
      Wire.begin();
      if (!RTC.begin()) {
        logfile.println("RTC failed");
    #if ECHO_TO_SERIAL
        Serial.println("RTC failed");
    #endif  //ECHO_TO_SERIAL
      }
      
      logfile.println("millis,timestamp,datetime,*10^-1 deg C,Pa,vcc");    
    #if ECHO_TO_SERIAL
      Serial.println("millis,timestamp,datetime,*10^-1 deg C,Pa,vcc");
    #endif //ECHO_TO_SERIAL
     
      // If you want to set the aref to something other than 5v
    //  analogReference(EXTERNAL);
      
      bmp085Calibration();
    }
    
    void loop() {
      DateTime now;
      
      // delay for the amount of time we want between readings
      delay((LOG_INTERVAL -1) - (millis() % LOG_INTERVAL));
      
      digitalWrite(greenLEDpin, HIGH);
      
      // log milliseconds since starting
      uint32_t m = millis();
      logfile.print(m);           // milliseconds since start
      logfile.print(",");    
    #if ECHO_TO_SERIAL
      Serial.print(m);         // milliseconds since start
      Serial.print(",");  
    #endif
    
      // fetch the time
      now = RTC.now();
      // log time
      logfile.print(now.unixtime()); // seconds since 1/1/1970
      logfile.print(",");
      logfile.print('"');
      logfile.print(now.year(), DEC);
      logfile.print("/");
      logfile.print(now.month(), DEC);
      logfile.print("/");
      logfile.print(now.day(), DEC);
      logfile.print(" ");
      logfile.print(now.hour(), DEC);
      logfile.print(":");
      logfile.print(now.minute(), DEC);
      logfile.print(":");
      logfile.print(now.second(), DEC);
      logfile.print('"');
    #if ECHO_TO_SERIAL
      Serial.print(now.unixtime()); // seconds since 1/1/1970
      Serial.print(",");
      Serial.print('"');
      Serial.print(now.year(), DEC);
      Serial.print("/");
      Serial.print(now.month(), DEC);
      Serial.print("/");
      Serial.print(now.day(), DEC);
      Serial.print(" ");
      Serial.print(now.hour(), DEC);
      Serial.print(":");
      Serial.print(now.minute(), DEC);
      Serial.print(":");
      Serial.print(now.second(), DEC);
      Serial.print('"');
    #endif //ECHO_TO_SERIAL
    
      temperature = bmp085GetTemperature(bmp085ReadUT());
      pressure = bmp085GetPressure(bmp085ReadUP());
      
      logfile.print(",");    
      logfile.print(temperature, DEC);
      logfile.print(",");    
      logfile.print(pressure, DEC);
    #if ECHO_TO_SERIAL
      Serial.print(",");   
      Serial.print(temperature, DEC);
      Serial.print(",");    
      Serial.print(pressure, DEC);
    #endif //ECHO_TO_SERIAL
    
    //  Serial.print("Temperature: ");
    //  Serial.print(temperature, DEC);
    //  Serial.println(" *0.1 deg C");
    //  Serial.print("Pressure: ");
    //  Serial.print(pressure, DEC);
    //  Serial.println(" Pa");
    //  Serial.println();
    //  delay(1000);
    
      // Log the estimated 'VCC' voltage by measuring the internal 1.1v ref
      analogRead(BANDGAPREF); 
      delay(10);
      int refReading = analogRead(BANDGAPREF); 
      float supplyvoltage = (bandgap_voltage * 1024) / refReading; 
      
      logfile.print(",");
      logfile.print(supplyvoltage);
    #if ECHO_TO_SERIAL
      Serial.print(",");   
      Serial.print(supplyvoltage);
    #endif // ECHO_TO_SERIAL
    
      logfile.println();
    #if ECHO_TO_SERIAL
      Serial.println();
    #endif // ECHO_TO_SERIAL
    
      digitalWrite(greenLEDpin, LOW);
    
      // Now we write data to disk! Don't sync too often - requires 2048 bytes of I/O to SD card
      // which uses a bunch of power and takes time
      if ((millis() - syncTime) < SYNC_INTERVAL) {
	    return;
      }
      syncTime = millis();
      
      // blink LED to show we are syncing data to the card & updating FAT!
      digitalWrite(redLEDpin, HIGH);
      logfile.flush();
      digitalWrite(redLEDpin, LOW);
      
    }
    
    // Stores all of the bmp085's calibration values into global variables
    // Calibration values are required to calculate temp and pressure
    // This function should be called at the beginning of the program
    void bmp085Calibration() {
      ac1 = bmp085ReadInt(0xAA);
      ac2 = bmp085ReadInt(0xAC);
      ac3 = bmp085ReadInt(0xAE);
      ac4 = bmp085ReadInt(0xB0);
      ac5 = bmp085ReadInt(0xB2);
      ac6 = bmp085ReadInt(0xB4);
      b1 = bmp085ReadInt(0xB6);
      b2 = bmp085ReadInt(0xB8);
      mb = bmp085ReadInt(0xBA);
      mc = bmp085ReadInt(0xBC);
      md = bmp085ReadInt(0xBE);
    }
    
    // Calculate temperature given ut.
    // Value returned will be in units of 0.1 deg C
    short bmp085GetTemperature(unsigned int ut) {
      long x1, x2;
    
      x1 = (((long)ut - (long)ac6)*(long)ac5) >> 15;
      x2 = ((long)mc << 11)/(x1 + md);
      b5 = x1 + x2;
    
      return ((b5 + 8)>>4);  
    }
    
    // Calculate pressure given up
    // calibration values must be known
    // b5 is also required so bmp085GetTemperature(...) must be called first.
    // Value returned will be pressure in units of Pa.
    long bmp085GetPressure(unsigned long up)
    {
      long x1, x2, x3, b3, b6, p;
      unsigned long b4, b7;
    
      b6 = b5 - 4000;
      // Calculate B3
      x1 = (b2 * (b6 * b6)>>12)>>11;
      x2 = (ac2 * b6)>>11;
      x3 = x1 + x2;
      b3 = (((((long)ac1)*4 + x3)<<OSS) + 2)>>2;
    
      // Calculate B4
      x1 = (ac3 * b6)>>13;
      x2 = (b1 * ((b6 * b6)>>12))>>16;
      x3 = ((x1 + x2) + 2)>>2;
      b4 = (ac4 * (unsigned long)(x3 + 32768))>>15;
    
      b7 = ((unsigned long)(up - b3) * (50000>>OSS));
      if (b7 < 0x80000000) {
        p = (b7<<1)/b4;
      } else {
        p = (b7/b4)<<1;
      }
    
      x1 = (p>>8) * (p>>8);
      x1 = (x1 * 3038)>>16;
      x2 = (-7357 * p)>>16;
      p += (x1 + x2 + 3791)>>4;
      return p;
    }
    
    // Read 1 byte from the BMP085 at 'address'
    char bmp085Read(unsigned char address) {
      unsigned char data;
      Wire.beginTransmission(BMP085_ADDRESS);
      Wire.write(address);
      Wire.endTransmission();
      Wire.requestFrom(BMP085_ADDRESS, 1);
      while(!Wire.available())
        ;
      return Wire.read();
    }
    
    // Read 2 bytes from the BMP085
    // First byte will be from 'address'
    // Second byte will be from 'address'+1
    int bmp085ReadInt(unsigned char address) {
      unsigned char msb, lsb;
      Wire.beginTransmission(BMP085_ADDRESS);
      Wire.write(address);
      Wire.endTransmission();
      Wire.requestFrom(BMP085_ADDRESS, 2);
      while(Wire.available()<2)
        ;
      msb = Wire.read();
      lsb = Wire.read();
      return (int) msb<<8 | lsb;
    }
    
    // Read the uncompensated temperature value
    unsigned int bmp085ReadUT() {
      unsigned int ut;
	  
      // Write 0x2E into Register 0xF4
      // This requests a temperature reading
      Wire.beginTransmission(BMP085_ADDRESS);
      Wire.write(0xF4);
      Wire.write(0x2E);
      Wire.endTransmission();
    
      // Wait at least 4.5ms
      delay(5);
    
      // Read two bytes from registers 0xF6 and 0xF7
      ut = bmp085ReadInt(0xF6);
      return ut;
    }
    
    // Read the uncompensated pressure value
    unsigned long bmp085ReadUP() {
      unsigned char msb, lsb, xlsb;
      unsigned long up = 0;
    
      // Write 0x34+(OSS<<6) into register 0xF4
      // Request a pressure reading w/ oversampling setting
      Wire.beginTransmission(BMP085_ADDRESS);
      Wire.write(0xF4);
      Wire.write(0x34 + (OSS<<6));
      Wire.endTransmission();
    
      // Wait for conversion, delay time dependent on OSS
      delay(2 + (3<<OSS));
    
      // Read register 0xF6 (MSB), 0xF7 (LSB), and 0xF8 (XLSB)
      Wire.beginTransmission(BMP085_ADDRESS);
      Wire.write(0xF6);
      Wire.endTransmission();
      Wire.requestFrom(BMP085_ADDRESS, 3);
    
      // Wait for data to become available
      while(Wire.available() < 3)
        ;
      msb = Wire.read();
      lsb = Wire.read();
      xlsb = Wire.read();
    
      up = (((unsigned long) msb << 16) | ((unsigned long) lsb << 8) | (unsigned long) xlsb) >> (8-OSS);
      return up;
    }
    

<script type="text/javascript"
    src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>