import processing.serial.*; //include the serial library

Serial port;

void setupNewtonmeter(String portname) {
  //String portname = Serial.list()[0];
  port = new Serial(this, portname, 9600);
}

float readNewton() {
  float newton = 0;
  // ask Newtonmeter to provide data
  if(port.available() > 0) { port.write("?"); }
  
  byte[] inBuffer = new byte[5];
  if(port.available() > 0) {
    inBuffer = port.readBytes();
    port.readBytes(inBuffer);
    if (inBuffer != null) {
      String force = new String(inBuffer);
      force = force.substring(1, force.length()-2);
      newton = float(force);
      //println(fv);
    }
  } 
  return newton;
}
