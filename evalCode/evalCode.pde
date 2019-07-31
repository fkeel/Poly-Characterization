//Data collection code for magnet-feedback experiment

//for logging data
import java.io.BufferedWriter; //log lines
import java.io.FileWriter; //create files

// for sending to arduino
import processing.serial.*;
Serial arduino;

int textileID; // serialStep1Step2 --> 000_000_0000 --> ID_Minutes_Minutes
int sampleID; // count the number of samples collected 
int textileReading; // ADC values
int textileVoltage; // transform ADC values to voltage;
int textileResistance; //calculate resistance based on voltage divider formula
int newton; // newton

String filename = "testrun2.txt";

int weightsPressure[] = {10, 20, 50, 100}; //populate array with weights to use in characterization
int weightsStrain[] = {10, 20, 50, 100}; //populate array with weights to use in characterization

int numberOfSamples = 300; //how many samples should be recorded
int numberOfConditions = 2; //pressure vs stretch
String[] conditions ={"Pressure",  "SquareResistance", "Stretch"}; //name of the conditions 
String[] actions ={"press",  "hold", "release"};  //name of the actions

int lineCounter = 0; //will be incremented with each writing
String currentCondition; 
String currentAction;
int currentRepetition; 

//log this --> ID, currentCondition, currentAction, currentRepitition, textileReading, textileResistance, newton

//some buttons to do stuff with
Button next;
Button previous;
Button pause;

//font to make things look nice
PFont font;

void setup() {


  textAlign(CENTER);
  font = createFont("arial", 18); //this is just for easthetics. 
  textFont(font);

  size(1000, 600);
  String portName = Serial.list()[0];
  println(portName);
  arduino = new Serial(this, portName, 9600);

  //initializing the buttons. The text is formatted like this: "name of button: button hotkey"
  next = new Button("next:n");
  previous = new Button("previous:p");
  pause = new Button("pause: ");


  //experiment logic
  currentCondition = 0;
  updateArduino();
}

void draw() {
  //set the background
  background(180, 170, 210);
  fill(255);
  textAlign(NORMAL);
  textAlign(CENTER);
  //display the buttons by providing them with x & y coordinate as well as height and width
  next.display(800, 400, 100, 60);
  pause.display(450, 400, 100, 60);
  

  //check if the buttons are clicked and do stuff if they are

  if (next.isToggled()) {
    //do something
    if (mousePressed && !next.isHover()) {
      next.toggle();
    }
    if (!mousePressed && next.isHover()) {
      goNext();
      next.toggle(); //switches button state
    }
  }

  if (previous.isToggled()) {
    //do something
    if (mousePressed && !previous.isHover()) {
      previous.toggle();
    }
    if (!mousePressed && previous.isHover()) {
      //step back
      previous.toggle(); //switches button state
      //currentCondition--; <--needs to be index (also check repititions
      updateConditions();
      updateArduino();
    }
  }


  if (pause.isToggled()) {
    // println(hapticsOn);
    //do something 
  } else {
    
  }
}

//function to call whenever participant confirms input
void goNext() {
//log this --> ID, currentCondition, currentAction, currentRepitition, textileReading, textileResistance, newton
  appendTextToFile(filename, textileID + ",\t ");
  appendTextToFile(filename, currentTime() + ",\t ");
  appendTextToFile(filename, currentCondition + ",\t\t ");
  appendTextToFile(filename, currentAction + ",\t\t ");
  appendTextToFile(filename, textileReading + ",\t\t ");
  appendTextToFile(filename, textileResistance + ",\t\t ");
  appendTextToFile(filename, newton + ",\t\t ");
  appendTextToFile(filename, "\r\n"); 
  lineCounter++;
  //println("We wrote data with the ID: " + lineCounter + " to the file");

 // currentCondition++;  <---- index update
  updateConditions();
  updateArduino();
}

String currentTime() {
  return String.valueOf(hour()) + ":" + String.valueOf(minute()) +  " " + String.valueOf(day()) +  "/"  + String.valueOf(month()) +  "/" +   String.valueOf(year());
}


void stop() {
  arduino.write("f 0 0");
}