//
// This Arduino sketch reads a DS18B20 "1-Wire" digital temperature sensor.
//
// This code is part of the BioBridge Project.
//
// Some code here is based on code from hacktronics:
//   http://www.hacktronics.com/Tutorials/arduino-1-wire-tutorial.html
// We thank them for sharing their knowledge!
//
//  author: rolf van widenfelt (c) 2011
//
// revision history:
//
//  apr 27, 2011 - rolf
//    changes to BioBoard protocol to match Marc's server code.
//
//  apr 25, 2011 - rolf
//    identify this probe.  (needed for BioBoard protocol)
//
//  apr 17, 2011 - rolf
//    change project name to "TESTBATCH1".
//
//  apr 12, 2011 - rolf
//    change serial port to 19200 baud.  (need to set Serial Monitor to the same, if you use that)
//
//  apr 11, 2011 - rolf
//    add functions (but comment out for now):
//      outputTCSample(probeid, tempC)
//      outputTCError(probeid, errcode)
//
//  apr 10, 2011 - rolf
//    just comments.
//
//  apr 7, 2011 - rolf
//    created.  tested with DS18B20 and seems to work.
//
// hardware setup:
//  1. any arduino (5volt)
//  2. DS18B20 digital temperature sensor (DTS) - note: get part number "DS18B20+"
//    pin 1 - connect to GND
//    pin 2 - connect to a 4.7K pullup (to PWR) and to digital pin 3 on the Arduino
//    pin 3 - connect to PWR (+5v)
//    (please refer to DS18B20 datasheet, page 1, to ensure the correct pinout)
//
// code modification:
//  you will need to get the "address" of your particular DS18B20 (each one is different!),
//  by running another sketch called "one_wire_address_finder".
//  it should print out a sequence of 8 numbers that look something like this:
//    0x28, 0x69, 0xCC, 0x4E, 0x03, 0x00, 0x00, 0x59
//
//  those numbers need to be substituted in the array below.
//  take care to get it exactly right, or this demo won't work.
//
// description:
//  this sketch will output a short string that contains the temperature
//  along with some other fields that indicate which probe (0) is being read and that this
//  is temperature in degrees C (TC).
//  the string should look like this for a temperature of 23.5:
//
//    @TC:0:23.50$
//
//  this is output periodically, over and over.  (in this case, probably every 2 sec)
//
//  In the case of an error, an "E" message is output instead of the temperature, like this:
//
//    @TC:0:EGETTEMP$
//
//  note that these data packets are output to the serial console window at 9600 baud.

//  also, when the sketch first starts, it identifies the software and version, like this:
//
//    @ID:BIOBOARD:TESTBATCH1:0.1$
//
//  and then it identifies the probe it is using, like this:
//
//    @PR:TC:0$
//
//  that's it!
//

#include <OneWire.h>
#include <DallasTemperature.h>

// Data wire is plugged into pin 3 on the Arduino
#define ONE_WIRE_BUS 3

// Setup a oneWire instance to communicate with any OneWire devices
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);

// Assign the addresses of your 1-Wire temp sensors.
// See the tutorial on how to obtain these addresses:
// http://www.hacktronics.com/Tutorials/arduino-1-wire-address-finder.html

// this is the address of our DS18B20 part:
DeviceAddress insideThermometer = { 0x28, 0x69, 0xCC, 0x4E, 0x03, 0x00, 0x00, 0x59 };


static const char ProjectName[] = "BATCH1";


void setup(void)
{
  // start serial port
  //Serial.begin(9600);
  Serial.begin(19200);
  // Start up the library
  sensors.begin();
  // set the resolution to 10 bit (good enough?)
  sensors.setResolution(insideThermometer, 10);
  
  Serial.print("!BIOBOARD:0.1\n\r");
  delay(500);  // just for fun
  Serial.print("@PROJ:");
  Serial.print(ProjectName);
  Serial.print("$\n\r");
  delay(500);  // just for fun

  // identify this probe
  Serial.print("@PR:TC:0$\n\r");

  // end of probes (do we need this?)
  Serial.print("@PREND$\n\r");
}


void printTemperature(DeviceAddress deviceAddress)
{
  float tempC = sensors.getTempC(deviceAddress);
  if (tempC == -127.00) {
    Serial.print("EGETTEMP");    // oops, can't get temperature so output an "E" message.
  } else {
    Serial.print(tempC);
  }
}


void loop(void)
{ 
  delay(2000);
  //Serial.print("Getting temperatures...\n\r");
  sensors.requestTemperatures();
  
  //Serial.print("Inside temperature is: ");
  //printTemperature(insideThermometer);
  //Serial.print("\n\r");
  
  Serial.print("@TC:0:");
  printTemperature(insideThermometer);
  Serial.print("$\n\r");
}


#ifdef NOTDEF
void outputTCSample(byte probeid, float tempC)
{
  Serial.print("@TC:");
  Serial.print(probeid);
  Serial.print(":");
  Serial.print(tempC);
  Serial.print("$\n\r");
}


void outputTCError(byte probeid, byte errcode)
{
  Serial.print("@TC:");
  Serial.print(probeid);
  Serial.print(":");
  if (errcode > 0) {
    Serial.print("EGETTEMP");
  }
  Serial.print("$\n\r");
}
#endif

