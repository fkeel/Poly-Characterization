

void calculateResistance() {
  //find the voltage
  for (int i = 0; i < numberOfresister2; i++) { //pull pins high one at a time and read, then pull low again.
    voltOut[i] = map(incomingValues[i], 0, 4096, 0, voltIn); //map to millivolt
  }

  //calculate the resistance
  for (int i = 0; i < numberOfresister2; i++) { //pull pins high one at a time and read, then pull low again.

    // R1 = ((Vi * R2) - (Vout * R2)) / Vout

    // calculating first two parts
    float VinXr2 = voltIn*resistor2Values[i]; // in Volt (Vin * R2)
  //  println(VinXr2);
    float VoutXr2 = voltOut[i]*resistor2Values[i]; //voltOut is in Millivolt, so it needs to be divided to fix scaling (Vout * R2)
  //  println(VoutXr2);
  //  println("end");
    resistanceEstimates[i] = ((VinXr2 - VoutXr2)/ (voltOut[i])); //again adjusting for millivolt
  }
}

void choseResisance() {
  //select the most reliable resistance
}