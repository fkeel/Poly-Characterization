//Data collection code for magnet-feedback experiment

//for logging data
import java.io.BufferedWriter; //log lines
import java.io.FileWriter; //create files

//----------Serial---------------//
import processing.serial.*; //include the serial library

Serial arduinoPort;  // The serial port at which we listen to data from the Arduino 
String rawIncomingValues; //this is where you dump the content of the serial port
int[] incomingValues = { 0, 0, 0, 0, 0, 0, 0 };     //this is where you will store the incoming values, so you can use them in your program
int token = 10; //10 is the linefeed number in ASCII
//You can replace it with whatever symbol marks the end of your line (http://www.ascii-code.com/)
boolean connectionEstablished = false;
//---------end--Serial----------//


//----------Configure ReadingToResistance Stuff---------------//


long resistor2Values[] = {10000000, 1000000, 100000, 10000, 1000, 220, 10};
float voltage = 3.3;
float[] calculatedVoltages  = { 0, 0, 0, 0, 0, 0, 0 }; 
float[] calculatedResistance  = { 0, 0, 0, 0, 0, 0, 0 }; 
int midPoint = 1024; //use this for chosing which resistance calculation is the most reliable

//----------------------------------------------------------//

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
String[] conditions ={"PressureDynamics", "Pressure",  "SquareResistance", "Stretch"}; //name of the conditions 


int lineCounter = 0; //will be incremented with each writing
int currentCondition = 0;
String currentConditionName; 
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
  
  //--------Serial-----------//
    // List all the available serial ports
  println("these are the available ports: ");
  printArray(Serial.list());
  //chose your serial port, by putting the correct number in the square brackets 
  //you might need to just trial and error this, the first time you do it
  String serialPort = Serial.list()[0];
  //check if you are using the port you think you are using
  println("You are using this port: " + serialPort);
  // Open the port with the same baud rate you set in your arduino
  arduinoPort = new Serial(this, serialPort, 9600);
 //-----------endSerial------------//
 
  //initializing the buttons. The text is formatted like this: "name of button: button hotkey"
  next = new Button("next:n");
  previous = new Button("previous:p");
  pause = new Button("pause: ");


  //experiment logic
 // currentCondition = 0; <--- index/samples
  updateArduino();
}

void draw() {
  //set the background
  background(180, 170, 210);
  fill(255);

  textAlign(CENTER);
  
  //experimental Logic
//  if(currentConditionName.equals("PressureDynamics")){
   //start measuring (maybe time this too?)
   //flag pressure onset
   //time until end of pressure
   //time until end of measure
//  } else if (currentConditionName.equals("Pressure")){
    //for(each weight){
      //place weight
      //wait for stabilize
      //collect 200 samples
    //}
//  } else if (currentConditionName.equals("SquareResistance"){
    //apply clamps
    //make fabric as relaxed as possible
    //wait for stablize
    //collect 200 samples
//  } else if (currentConditionName.equals("Stretch"){
    //note the direction of stretch (input field!)
    //apply 500g
    //release
    //start measuring (loop through weights)
//  }
  
  


//stretch in direction of the courses: https://www.kobakant.at/DIY/?p=5689

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