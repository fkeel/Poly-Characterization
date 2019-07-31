//this is just here so we can re-use it for the sliders

//buttons must be initialzied
//once drawn, buttons track if they are toggled or not
//you can toggle by clicking or by using the hotkey

public class Button {
  int buttonX, buttonY, buttonWidth, buttonHeight; //position & dimensions
  int nameOffsetX, nameOffsetY; //where to draw labels
  boolean state; //on / off
  String buttonName; //name to be displayed
  char hotKey; //keyboard shortcut for toggling button
  boolean readyForClick;
  boolean clicked; //true if currently clicked
  boolean hotKeyHit; //true if the hotkey is currently being pushed

  boolean displayName;

  boolean checkMouse; //set false to deactivate mouse input
  boolean checkKey; //set false to deactivate keyboard shortcuts

  boolean debounce = false; //do not toggle multiple times with one hotkey
  boolean mouseDebounce = false; //do not toggle multiple times with one click

  color boxActive = color(0, 255, 0);
  color boxInactive = color(255, 0, 0);

  color textActive = color(255, 0, 0);
  color textInactive = color(255);

  //createButton (its actually a switch)
  Button(String nameShortcut) {
    displayName = true;
    checkMouse = true;
    checkKey = true;
    hotKeyHit = false;
    clicked = false;
    buttonX = 0;
    buttonY = 0;
    buttonWidth = 100;
    buttonHeight = 100;
    nameOffsetX = 3;
    nameOffsetY = 15;
    readyForClick = false;
    //there was a logic for doing it like this once. Maybe its easier to just have a string and a char?
    String[] stringArray = splitTokens(nameShortcut, ":");
    if (stringArray.length != 2) {
      println("ERROR: Please format your buttons as \"ButtonName:Hotkey\" instead of \"" +nameShortcut+"\"");
    }
    buttonName = stringArray[0];
    hotKey = stringArray[1].charAt(0);
    println("Button Created - Name: " + buttonName + ", HotKey: " + hotKey);
    state = false;
  }


  //draw button. should follow the 'rect' logic
  //when button is not displayed, it also does not track if active or not
  void display(int x, int y, int w, int h) {
    buttonX = x;
    buttonY = y;
    buttonWidth = w;
    buttonHeight = h;
    fill(state? boxActive:boxInactive); //color of rectangle
    rect(buttonX, buttonY, buttonWidth, buttonHeight);
    if (displayName) {
      fill(state? textActive:textInactive); //color of name
      text(buttonName, buttonX+buttonWidth/2, buttonY+nameOffsetY+buttonHeight);
      // fill(state? highGreen:highRed);  //color of hotkey
    }

    //check if user is interacting with it
    if (checkMouse) {
      activateClick();
    }
    if (checkKey) {
      activateKey();
    }
  }



  //display label or not (dafault is on)
  void showLabel(boolean command) {
    displayName = command;
  }

  //switches state
  boolean toggle() {
    return state = !state;
  }

  //needs a toggle and a switch function

  //sets state
  void setState(boolean newState) {
    state = newState;
  }

  //asks for state
  boolean isToggled() {
    return state;
  }
  
    boolean isHover() {
    return hover();
  }

  boolean isClicked() {
    return clicked;
  }

  void activateClick() {
    //gotta check if another one is not still clicked
    if (!mousePressed && hover()) {
      readyForClick = true;
      mouseDebounce = false;
    }
    if (mousePressed && readyForClick && !mouseDebounce && hover()) {
      this.toggle();
      mouseDebounce = true;
    } 

    //see if its being pressed
    if (mousePressed && hover()) {
      clicked = true;
    }

    if (!mousePressed || !hover()) {
      clicked = false;
    }
  }


  //on press behavior
  void activateKey() {

    if (keyPressed) {     
      if (key == hotKey)
        hotKeyHit = true;
    } 
    if (hotKeyHit && !debounce) {
      toggle();
      debounce = true;
    } 

    if (keyPressed) {
      if (key != hotKey)
        hotKeyHit = false;
    } 

    if (!keyPressed) {
      hotKeyHit = false;
      debounce = false;
    }
  }

  //checks if curser is within bounds
  boolean hover() {
    return mouseX > buttonX & mouseX < buttonX+buttonWidth 
      & mouseY > buttonY & mouseY < buttonY+buttonHeight;
  }
  /// messing with colors
  void inactiveFill(int a, int b, int c) {
    boxInactive = color(a, b, c);
  }
  void inactiveFill(int a, int b, int c, int d) {
    boxInactive = color(a, b, c, d);
  }

  void activeFill(int a, int b, int c) {
    boxActive = color(a, b, c);
  }
  void activeFill(int a, int b, int c, int d) {
    boxActive = color(a, b, c, d);
  }
  //text
  void inactiveTextFill(int a, int b, int c) {
    textInactive = color(a, b, c);
  }
  void inactiveTextFill(int a, int b, int c, int d) {
    textInactive = color(a, b, c, d);
  }

  void activeTextFill(int a, int b, int c) {
    textActive = color(a, b, c);
  }
  void activeTextFill(int a, int b, int c, int d) {
    textActive = color(a, b, c, d);
  }
  /*
// key release behavior
   //could have a boolean somwehre that determines behavior
   void activateKey() {
   if (keyPressed) {
   if (key == hotKey)
   hotKeyHit = true;
   } 
   if (hotKeyHit && !keyPressed) {
   toggle();
   } 
   
   if (keyPressed) {
   if (key != hotKey)
   hotKeyHit = false;
   } 
   
   if (!keyPressed) {
   hotKeyHit = false;
   }
   }
   
   //clickReleaseBehavior
   void activateClick() {
   //gotta check if another one is not still clicked
   if (!mousePressed && hover()) {
   readyForClick = true;
   }
   
   if (mousePressed && hover() && readyForClick) {
   clicked = true;
   } 
   
   if (clicked && hover() && !mousePressed) {
   toggle();
   } 
   
   if (!mousePressed || !hover()) {
   clicked = false;
   }
   }
   
   */
}