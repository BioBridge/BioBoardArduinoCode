//
// This Arduino sketch reads our custom NIR absorption sensor.
//
// This code is part of the BioBridge Project.
//
//
//  author: rolf van widenfelt (c) 2011
//
// revision history:
//
//  apr 25, 2011 - rolf
//    identify this probe.  (needed for BioBoard protocol)
//
//  apr 17, 2011 - rolf
//    created.
//    ADC code seems to work.. still need to connect actual sensor and document connections!
//
//
// code modification:
//  you will need to set some calibration points... (FILL THIS IN!!)
//
// description:
//  this sketch will periodically output a short string that contains the NIR transmittance
//  along with some other fields that indicate which probe (0) is being read.
//  the string should look like this for a transmittance of 99% :
//
//    @NIR:0:0.99$
//
//  this is output periodically.  (in this case, every 5 sec)
//
//  In the case of an error, an "E" message is output instead of the temperature, like this:
//
//    @TC:0:EBADVALUE$
//
//  note that these data packets are output to the serial console window at 19200 baud.

//  also, when the sketch first starts, it identifies the software and version, like this:
//
//    @ID:BIOBOARD:TESTBATCH1:1.1$
//
//  that's it!
//


static const char ProjectName[] = "TESTBATCH1";

const int analogNIRPin = A0;  // analog input pin that the NIR phototransistor circuit is connected to

// CALIBRATION SETTINGS
#define IMAX 4.9    /* max phototransistor current with IR LED on (no obstructions, just 1inch air) */
#define IMIN 0.02    /* dark current (NOTUSED) */
#define VMAX 5.0    /* arduino voltage = 5.0v */


#define ADCMAX 1023    /* highest ADC value */
#define IMAXI (ADCMAX*IMAX/VMAX)   /* highest ADC value we expect from our sensor */
#define IMAXI_INV (1.0/(ADCMAX*IMAX/VMAX))   /* inverse (this avoids a divide during runtime) */

void setup(void)
{
  // start serial port
  //Serial.begin(9600);
  Serial.begin(19200);
  
  Serial.print("\n\r@ID:BIOBOARD:");
  Serial.print(ProjectName);
  Serial.print(":0.1$\n\r");

  // configure ADC to use external 5v reference (default)
  analogReference(DEFAULT);

  // just in case, throw away 1st ADC read
  (void) analogRead(analogNIRPin);
  
  // identify this probe
  Serial.print("@PR:NIR:0$\n\r");
}


void printNIR()
{
  
  int sensor = analogRead(analogNIRPin);
  float sample = IMAXI_INV * sensor;

  if (sensor > IMAXI + 10) {
    Serial.print("EBADVALUE");    // oops, value is clearly wrong, so output an "E" message.
  } else {
    Serial.print(sample);
  }

  // XXX debug - we output raw ADC value as well
  Serial.print(":");
  Serial.print(sensor);

}


void loop(void)
{ 
  delay(2500);
  
  Serial.print("@NIR:0:");
  printNIR();
  Serial.print("$\n\r");
}

