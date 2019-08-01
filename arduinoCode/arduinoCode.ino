#ifdef CORE_TEENSY
const int ADCbitDepth = 12;
#else
const int ADCbitDepth = 10; // typical arduino MCUs use 10bits ADC
#endif

// To calculate the resistance on the teensy, uncomment the following:
//#define EMBED_RESISTANCE_CALCULATION

const int analogInPin = A5;  // Input from polymerized sensor
const int resistor2Pin[] =      {       2,       3,      4,      5,     6,     7,    8,    9,  10,  11, 15, 16,  17};
const float resistor2Values[] = {10000000, 1000000, 330000, 100000, 47000, 10000, 4700, 1000, 470, 220, 47, 10, 4.7};
const int numberOfResistors = 13; //this need not be a magic number
const float Vin = 3.3; // Update this, if you're using a 5v board

int adcReadings[numberOfResistors] = {0}; //array for storing the readings


void setup() {
  // initialize serial communications at 9600 bps:
  Serial.begin(9600);
  analogReadResolution(ADCbitDepth);
  pinMode(analogInPin, INPUT);
  for (int i = 0; i < numberOfResistors; i++) { //set all pins as input, so that no current can flow
    pinMode(resistor2Pin[i], INPUT);
  }
}


void loop() {


#ifdef EMBED_RESISTANCE_CALCULATION
  //if we want to calculate the resistance on the teensy
  float voltOut[numberOfResistors] = {0}; //array for storing the voltages (won't be used)
  float resistanceEstimates[numberOfResistors] = {0}; //array for storing the resistances (won't be used)

    //find the voltage
     for (int i = 0; i < numberOfResistors; i++) { //pull pins high one at a time and read, then pull low again.
      voltOut[i] = map(adcReadings[i] , 0,1<<ADCbitDepth , 0,5000)/1000.0; //map to millivolt
    }

    //calculate the resistance
    for (int i = 0; i < numberOfResistors; i++) { //pull pins high one at a time and read, then pull low again.

     //calculate resistor 1 using the formula Vout = Vin (R2/R1+r2)
     //resistor 1 is the polymerized textile we want to measure
     //resistor 2 are switchable resistors in the following range:
     // R1 = ((Vi * R2) - (Vout * R2)) / Vout

     // calculating first two parts
      float VinXr2 = Vin*float(resistor2Values[i]); // in Volt (Vin * R2)
      float VoutXr2 = voltOut[i]*float(resistor2Values[i]); //voltOut is in Millivolt, so it needs to be divided to fix scaling (Vout * R2)

      resistanceEstimates[i] = (VinXr2- VoutXr2)/ voltOut[i]; //again adjusting for millivolt
    }

  //print to serial
  for (int i = 0; i < numberOfResistors - 1; i++) { //set all pins as input, so that no current can flow
    Serial.print(resistanceEstimates[i]);
    Serial.print(", ");
  }
  Serial.println(resistanceEstimates[numberOfResistors - 1]);
  //end print to serial

//ToDo: Add function that selects the best estimate of resistance. Chose the voltage divider where Vout is closest to Vin/2

#else

  for (int i = 0; i < numberOfResistors; i++) { //pull pins high one at a time and read, then pull low again.
    pinMode(resistor2Pin[i], OUTPUT);
    int averageNum = 3;
    adcReadings[i] = 0;
    for (int a = 0; a < averageNum; a++)
        adcReadings[i] += analogRead(analogInPin); //some averaging, to decrease noise
    adcReadings[i] = adcReadings[i] / averageNum;
    pinMode(resistor2Pin[i], INPUT);
  }

  //print to serial
  for (int i = 0; i < numberOfResistors - 1; i++) { //set all pins as input, so that no current can flow
    Serial.print(adcReadings[i]);
    Serial.print(", ");
  }
  Serial.println(adcReadings[numberOfResistors - 1]);
  //end print to serial

#endif

  delay(10);
}
