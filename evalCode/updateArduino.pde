void updateArduino() {
  /*
  //write to arduino
  arduino.write("f 0 0");
  delay(30);
  //write 
  arduino.write("u " + frequencyCondition + " " + pulseWidthCondition);
  println("u " + frequencyCondition + " " + pulseWidthCondition);
  delay(30);
  arduino.write("s 0 0");
  hapticsOn = true;
  */
}

void updateNewtonmeter() {
  /*
  //write to arduino
  arduino.write("f 0 0");
  delay(30);
  //write 
  arduino.write("u " + frequencyCondition + " " + pulseWidthCondition);
  println("u " + frequencyCondition + " " + pulseWidthCondition);
  delay(30);
  arduino.write("s 0 0");
  hapticsOn = true;
  */
}



//This is the function that receives and parses the data
//it executes whenever data is received 
void serialEvent(Serial arduinoPort) { 
  //we read the incoming data until we have found our toke (its defined at the top, but can be any character
  rawIncomingValues = arduinoPort.readStringUntil(token);
  //if there actually is a valid incoming value, we use the splitTokens
  //this splits the incoming string into an array of integers that is easy to work with
  if (rawIncomingValues != null) {
    incomingValues = int(trim(splitTokens(rawIncomingValues, ",")));
  //  println(incomingValues);
    connectionEstablished = true; 
  }
} 