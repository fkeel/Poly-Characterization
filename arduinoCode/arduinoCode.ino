
int analogInPin = A5;  // Input from polymerized sensor
int numberOfresister2 = 7;
int resistor2Pin[] = {6, 12, 11, 10, 9, 8, 7};
long resistor2Values[] = {10000000, 1000000, 100000, 10000, 1000, 220, 10};
float Vin = 5;

//resistor 1 is the polymerized textile we want to measure
//resistor 2 are switcheable resistors in the following range:

//D06 - 10 mega
//d12 - 1 mega
//d11 - 100k
//d10 - 10k
//d09 - 1k
//d08 - 220
//d07 - 10

//calculate resistor 1 using the formula Vout = Vin (R2/R1+r2)
int a = 2;
int adcReadings[] = {0, 0, 0, 0, 0, 0, 0}; //array for storing the readings

float voltOut[] = {0, 0, 0, 0, 0, 0, 0}; //array for storing the readings
float resistanceEstimates[] = {0, 0, 0, 0, 0, 0, 0}; //array for storing the readings

void setup() {
  // initialize serial communications at 9600 bps:
  Serial.begin(9600);
  for (int i = 0; i < numberOfresister2; i++) { //set all pins as input, so that no current can flow
    pinMode(resistor2Pin[i], INPUT);
  }
}

void loop() {


  for (int i = 0; i < numberOfresister2; i++) { //pull pins high one at a time and read, then pull low again.
    pinMode(resistor2Pin[i], OUTPUT);
    delay(2);
    adcReadings[i] = analogRead(analogInPin);
    adcReadings[i] = analogRead(analogInPin);
    adcReadings[i] = analogRead(analogInPin);
    pinMode(resistor2Pin[i], INPUT);
  }

//find the voltage
   for (int i = 0; i < numberOfresister2; i++) { //pull pins high one at a time and read, then pull low again.  
    voltOut[i] = map(adcReadings[i],0,1023,0,5000)/1000.0; //map to millivolt  
  }




  //calculate the resistance
  for (int i = 0; i < numberOfresister2; i++) { //pull pins high one at a time and read, then pull low again.  

   // R1 = ((Vi * R2) - (Vout * R2)) / Vout
   
   // calculating first two parts
    float VinXr2 = Vin*float(resistor2Values[i]); // in Volt (Vin * R2)
    float VoutXr2 = voltOut[i]*float(resistor2Values[i]); //voltOut is in Millivolt, so it needs to be divided to fix scaling (Vout * R2)
    
    resistanceEstimates[i] = (VinXr2- VoutXr2)/ voltOut[i]; //again adjusting for millivolt
  }

//print to serial
    for (int i = 0; i < numberOfresister2-1; i++) { //set all pins as input, so that no current can flow
    Serial.print(resistanceEstimates[i]);
    Serial.print(", ");
  }
  Serial.println(resistanceEstimates[numberOfresister2-1]);
//end print to serial


  //outputValue = map(sensorValue, 0, 1023, 0, 255);  // change the analog out value:

  // wait 2 milliseconds before the next loop
  // for the analog-to-digital converter to settle
  // after the last reading:
  delay(10);
}
