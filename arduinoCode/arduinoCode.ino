
int analogInPin = A5;  // Input from polymerized sensor
int numberOfresister2 = 7;
int resistor2Pin[] = {6, 12, 11, 10, 9, 8, 7};

//resistor 1 is the polymerized textile we want to measure
//resistor 2 are switcheable resistors in the following range:

//D13 - 10 mega
//d12 - 1 mega
//d11 - 100k
//d10 - 10k
//d09 - 1k
//d08 - 220
//d07 - 10

//calculate resistor 1 using the formula Vout = Vin (R2/R1+r2)
int a = 2;
int adcReadings[] = {0, 0, 0, 0, 0, 0, 0}; //array for storing the readings


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
    pinMode(resistor2Pin[i], INPUT);
  }

//print to serial
    for (int i = 0; i < numberOfresister2-1; i++) { //set all pins as input, so that no current can flow
    Serial.print(adcReadings[i]);
    Serial.print(", ");
  }
  Serial.println(adcReadings[numberOfresister2-1]);
//end print to serial


  //outputValue = map(sensorValue, 0, 1023, 0, 255);  // change the analog out value:

  // wait 2 milliseconds before the next loop
  // for the analog-to-digital converter to settle
  // after the last reading:
  delay(10);
}
