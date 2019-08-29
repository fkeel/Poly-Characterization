//Data collection code for magnet-feedback experiment
String filename = "003_015_060.csv";
String textileID = "003_015_060"; // serialStep1Step2 --> 000_000_0000 --> ID_Minutes_Minutes

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


long resistor2Values[] = {10000000, 1000000, 100000, 10000, 1000, 220, 10}; //
float voltIn = 3.3;
float[] calculatedVoltages  = { 0, 0, 0, 0, 0, 0, 0 };
float[] calculatedResistance  = { 0, 0, 0, 0, 0, 0, 0 };
int midPoint = 1024; //use this for chosing which resistance calculation is the most reliable
int numberOfresister2 = 7;
float voltOut[] = {0, 0, 0, 0, 0, 0, 0}; //array for storing the voltages (won't be used)
float resistanceEstimates[] = {0, 0, 0, 0, 0, 0, 0}; //array for storing the resistances (won't be used)

String HEADER = "ID,Time,Task,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,Newton,Weight";

//----------------------------------------------------------//


int sampleID; // count the number of samples collected
int textileReading; // ADC values
int textileVoltage; // transform ADC values to voltage;
int textileResistance; //calculate resistance based on voltage divider formula
int newton; // newton


boolean spacePressed = false;
boolean recording = false;
int startTime = -1;
int countdown;
int[] taskDelays = { 15000 /*PressureDynamics*/, 2000 /*Pressure*/, 2000 /*Square*/, 2000 /*Stretching*/};
RecordManager recordM = new RecordManager();

int wid = 0;
int weightsPressure[] = {5, 10, 20, 50, 100, 200, 500}; //populate array with weights to use in characterization
int weightsStrain[] = {5, 10, 20, 50, 100, 200, 500}; //populate array with weights to use in characterization

int numberOfSamples = 300; //how many samples should be recorded
//int numberOfConditions = 4; //pressure vs stretch
String[] tasks ={"PressureDynamics", "Pressure", "SquareResistance", "Stretch"}; //name of the tasks
boolean weightPlaced = false;
int taskStage = 0;

int lineCounter = 0; //will be incremented with each writing
int currentTask = 0;
//String currentConditionName;
//int currentRepetition;

//log this --> ID, currentCondition, currentAction, currentRepitition, textileReading, textileResistance, newton

//----------------UI features-----------------//

//some buttons to do stuff with
Button next;
Button previous;
Button pause;
Button placeWeight;

String taskname;
String instructions = null;
String timer = "";
int[] pos_tn = { 500, 150 };
int[] pos_inst = { 500, 175 };
int[] pos_timer = { 500, 200 };

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
  next = new Button("next:x");
  previous = new Button("previous:z");
  pause = new Button("pause:p");
  placeWeight = new Button("nextWeight: ");

  //experiment logic
  // currentCondition = 0; <--- index/samples
  //updateArduino();

  setupNewtonmeter(Serial.list()[1]);
}


void draw() {
  //set the background
  background(180, 170, 210);
  fill(255);

  textAlign(CENTER);
  taskname = tasks[currentTask];
  //experimental Logic
  if (taskname.equals("PressureDynamics")) {
    //placeWeight.display(20, 20, 200, 200);
    //logLine();

    switch(taskStage) {
      case 0:
        if(instructions == null) { instructions = "Press the 'space' bar to start recording"; }
        if(spacePressed) {
          taskStage = 1;
          recordM.recordNM(true);
          recording = true;
          spacePressed = false;
          instructions = "Get ready";
          //startTime = millis();
          countdown = millis() + 5000;
        }
        break;
      case 1:
      background(250, 170, 210);
        if(countdown <= millis()) {
                      instructions = "Put the weight on the material";
          timer = null;
          taskStage = 2;
          //recording = false;
          startTime = millis();
        } else {
          int dt = countdown-millis();
          timer = (dt/1000) + ":" + (dt%1000);
        }
        break;
      case 2:
        if(recording) {
          int dt = millis() - startTime;
          if(dt > taskDelays[currentTask]) {
              background(250, 170, 210);
            instructions = "Remove the weight from the material";
            timer = null;
            taskStage = 3;
            //recording = false;
            startTime = millis();
          } else {
            timer = (dt/1000) + ":" + (dt%1000);
          }
        }
        break;
      case 3:
        //if(spacePressed) { recording = true; spacePressed = false; startTime = millis(); }
        if(recording) {
          int dt = millis() - startTime;
          if(dt > taskDelays[currentTask]) {
            instructions = "Task finished (recording data)";
            timer = null;
            taskStage = 4;
          } else {
            timer = (dt/1000) + ":" + (dt%1000);
          }
        }
        break;
      case 4:
        recording = false;
        recordM.record(textileID, taskname, -1);
        instructions = "Data recorded in "+filename+"!";
        taskStage = 5;
        break;
      case 5:
        break;
      }
  } else if (taskname.equals("Pressure")) {
    switch(taskStage) {
      case 0:
        if(instructions == null) {
          if(wid < weightsPressure.length) { instructions = String.format("Place %dg on the material (Spacebar starts recrording)", weightsPressure[wid]); }
          else { taskStage = 3; }
        }
        if(spacePressed) {
          taskStage = 1;
          recordM.recordNM(true);
          recording = true;
          spacePressed = false;
          instructions = "Recording...";
          startTime = millis();
        }
        break;
      case 1:
        int dt = millis() - startTime;
        timer = (dt/1000) + ":" + (dt%1000);
        if(dt > taskDelays[currentTask]) {
          instructions = String.format("Remove the weight from the material (saving data in %s)", filename);
          timer = null;
          taskStage = 2;
        }
        break;
      case 2: // saving data
        recording = false;
        recordM.record(textileID, taskname, weightsPressure[wid]);
        instructions = null;
        wid++;
        taskStage = 0;
        break;
      case 3:
        instructions = "All data recorded in "+filename+"!";
        break;
    }
  } else if (taskname.equals("SquareResistance")) {
    switch(taskStage) {
      case 0:
        if(instructions == null) { instructions = "Place the electrodes on the material (SWAP ELECTRODES)"; }
        if(spacePressed) {
          taskStage = 1;
          recordM.recordNM(false);
          recording = true;
          spacePressed = false;
          instructions = "Recording...";
          startTime = millis();
        }
        break;
      case 1:
        int dt = millis() - startTime;
        timer = (dt/1000) + ":" + (dt%1000);
        if(dt > taskDelays[currentTask]) {
          instructions = String.format("Task finished (recording data)", filename);
          timer = null;
          taskStage = 2;
        }
        break;
      case 2:
        recording = false;
        recordM.record(textileID, taskname, -1);
        taskStage = 3;
        break;
      case 3:
        instructions = "All data recorded in "+filename+"!";
        break;
    }
  } else if (taskname.equals("Stretch")) {
        switch(taskStage) {
      case 0:
        if(instructions == null) {
          if(wid < weightsPressure.length) { instructions = String.format("Stretch the material with %dg", weightsStrain[wid]); }
          else { taskStage = 3; }
        }
        if(spacePressed) {
          taskStage = 1;
          recordM.recordNM(false);
          recording = true;
          spacePressed = false;
          instructions = "Recording...";
          startTime = millis();
        }
        break;
      case 1:
        int dt = millis() - startTime;
        timer = (dt/1000) + ":" + (dt%1000);
        if(dt > taskDelays[currentTask]) {
          instructions = String.format("Remove the weight (saving data in %s)", filename);
          timer = null;
          taskStage = 2;
        }
        break;
      case 2:
        recording = false;
        recordM.record(textileID, taskname, weightsStrain[wid]);
        instructions = null;
        wid++;
        taskStage = 0;
        break;
      case 3:
        instructions = "All data recorded in "+filename+"!";
        exit();
        break;
    }
  }


  //for (int i = 0; i < numberOfresister2 - 1; i++) { //set all pins as input, so that no current can flow
  //  print(resistanceEstimates[i]);
  //  print(", ");
  //}
  //println(resistanceEstimates[numberOfresister2 - 1]);


  // for debugging
  //if(recording) {
  //  recordM.addValues(new int[]{ 0, 1, 2, 3, 4, 5, 6, 7, 8 });
  //  recordM.addNMValue(10);
  //}



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
      //  goNext();
      next.toggle(); //switches button state
      updateTask(currentTask+1);
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
      updateTask(currentTask-1);
      //updateArduino();
    }
  }


  if (pause.isToggled()) {
    // println(hapticsOn);
    //do something
  } else {
  }

  textAlign(LEFT);
  if(taskname != null && taskname.length() != 0) {
    text(taskname, pos_tn[0], pos_tn[1]);
  }
  if(instructions != null && instructions.length() != 0) {
    text(instructions, pos_inst[0], pos_inst[1]);
  }
  if(timer != null && timer.length() != 0) {
    text(timer, pos_timer[0], pos_timer[1]);
  }
}

void keyPressed() {
  if (key == ' ') { // space bar pressed
    spacePressed = true;
  }
  //println("Key pressed: "+key);
}

// write a different function for each task?
//void logLine() {
//  // missing:
//  // incoming value, newton (computed by Newtonmeter),

//  //log this --> ID, currentCondition, currentAction, currentRepitition, textileReading, textileResistance, newton
//  appendTextToFile(filename, textileID + ",\t ");
//  appendTextToFile(filename, currentTime() + ",\t ");
//  appendTextToFile(filename, currentTask + ",\t\t ");
//  appendTextToFile(filename, textileReading + ",\t\t ");
//  appendTextToFile(filename, textileResistance + ",\t\t ");
//  appendTextToFile(filename, newton + ",\t\t ");
//  appendTextToFile(filename, weightPlaced + ",\t\t ");
//  appendTextToFile(filename, "\r\n");
//  lineCounter++;
//  //println("We wrote data with the ID: " + lineCounter + " to the file");
//}


void updateTask(int tid) {
  currentTask = tid;
  taskStage = 0;
  instructions = null;
  wid = 0;
  timer = null;
  spacePressed = false;
  if (currentTask < 0 || currentTask == tasks.length) {
    currentTask = 0;
    //currentRepetition++;
  }
  //if (currentRepetition == numberOfRepititions) {
  //  fill(100);
  //  rect(0, 0, width, height);
  //  fill(255);
  //  text("DONE!", width/2, height/2);
  //  arduino.write("f 0 0");
  //  noLoop();
  //}
  //write to arduino
  //write
  //frequency condition is frequency (as chosen from the freqSelector, as determined by random number)
  //frequencyCondition = frequency[freqSelector[randomCondition[(participantID*3)+currentRepetition][currentCondition]]];
  //pulseWidthCondition = duration[durationSelector[randomCondition[(participantID*3)+currentRepetition][currentCondition]]];
}

String currentTime() {
  return String.valueOf(hour()) + ":" + String.valueOf(minute()) +  " " + String.valueOf(day()) +  "/"  + String.valueOf(month()) +  "/" +   String.valueOf(year());
}
