import java.awt.event.KeyEvent;
import javax.swing.JOptionPane;
import processing.serial.*;

//++++++++++++++++++++++++++++
import controlP5.*;

ControlP5 controlP5;  
Println console;
Textarea constext;

PFont font;
//++++++++++++++++++++++++++++

Serial port = null;

String portname = "COM5";   // Your Arduino COM Port

boolean streaming = false;
float speed = 0.001;
String[] gcode;
int i = 0;

float l_val;
float x_val =0;
float y_val =0;

String testString;


void openSerialPort()
{
  if (portname == null) return;
  if (port != null) port.stop();
  
  port = new Serial(this, portname, 9600);
  
  port.bufferUntil('\n');
}

void selectSerialPort()
{
  String result = (String) JOptionPane.showInputDialog(frame,
    "Select the serial port that corresponds to your Arduino board.",
    "Select serial port",
    JOptionPane.QUESTION_MESSAGE,
    null,
    Serial.list(),
    0);
    
  if (result != null) {
    portname = result;
    openSerialPort();
  }
}

void setup()
{
  size(500, 510);
  surface.setLocation(400, 30);
  openSerialPort();
//+++++++++++++++++++++++++++++++++++++++++++  
  font = createFont("calibri", 16);    // custom fonts for buttons and title

  controlP5 = new ControlP5(this);
//+++++++++++++++++++++++++++++++++++++++++++  


    // F20
      controlP5.addButton("las_0") 
    .setPosition                                      (150, 465) 
    .setSize                                          (205 ,  20)  
    .setCaptionLabel("Laser OFF")   
    .setFont(font)
    .setColorBackground(color(200, 100, 0))
    .setColorForeground(color(250, 0, 0))
    .setColorValue(color(255, 255, 255))
    .setColorActive(color(119, 0, 0)) 
  ;
  font = createFont("calibri", 15);

 controlP5.addButton("s20")
     .setPosition                                    (150,440)
     .setSize                             (50,   20)
     .setId(5)
     .setCaptionLabel("20")
     .setColorBackground(color(0, 51, 0)) 
     .setColorForeground(color(0, 150, 0)) 
     .setColorValue(color(255, 255, 255)) 
     .setColorActive(color(119, 0, 0))  
     .setFont(font)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
  
  controlP5.addButton("s50")
     .setPosition                                    (228,440)
     .setSize                             (50,   20)
     .setId(5)
     .setCaptionLabel("50")
    .setColorBackground(color(200, 119, 0)) 
    .setColorForeground(color(220, 200, 0)) 
    .setColorValue(color(255, 255, 255)) 
    .setColorActive(color(119, 0, 0))  
     .setFont(font)
     .getCaptionLabel().align(CENTER,CENTER)
     ;

   controlP5.addButton("s255")
     .setPosition                                    (305,440)
     .setSize                             (50,   20)
     .setId(5)
     .setCaptionLabel("255")
     .setColorBackground(color(180, 0, 0)) 
     .setColorForeground(color(255, 0, 0)) 
     .setColorValue(color(255, 255, 255)) 
     .setColorActive(color(119, 0, 0))   
     .setFont(font)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
 
font = createFont("calibri", 16);

       controlP5.addButton("f1") 
    .setPosition                                      (330,125) 
    .setSize                                          (48 , 20)   
    .setCaptionLabel("F 7000")  
    .setFont(font)
    .setColorBackground(color(0, 180, 100))
    .setColorForeground(color(0, 0, 200)) 
    .setColorValue(color(255, 255, 255))
    .setColorActive(color(119, 0, 0))
  ;

       controlP5.addButton("f10") 
    .setPosition                                      (375,125) 
    .setSize                                          (48 , 20)   
    .setCaptionLabel("F 5000")  
    .setFont(font)
    .setColorBackground(color(0, 180, 100))
    .setColorForeground(color(0, 0, 200)) 
    .setColorValue(color(255, 255, 255))
    .setColorActive(color(119, 0, 0))
  ;

       controlP5.addButton("f200") 
    .setPosition                                      (422,125) 
    .setSize                                          (48 , 20)   
    .setCaptionLabel("F 1")  
    .setFont(font)
    .setColorBackground(color(0, 180, 100))
    .setColorForeground(color(0, 0, 200)) 
    .setColorValue(color(255, 255, 255))
    .setColorActive(color(119, 0, 0))
  ;
font = createFont("calibri", 15);

   controlP5.addButton("home")
     .setPosition                                    (330,240)
     .setSize                             (140,   30)
     .setId(5)
     .setCaptionLabel("home")
     .setColorBackground(color(0, 0, 100)) 
     .setColorForeground(color(0, 0, 200)) 
     .setColorValue(color(0, 100, 255)) 
     .setColorActive(color(0, 100, 255))  
     .setFont(font)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
     
font = createFont("calibri", 15);

   controlP5.addButton("sel_port")
     .setPosition                                    (11,465)
     .setSize                             (100,   20)
     .setId(5)
     .setCaptionLabel("select port")
     .setColorBackground(color(120, 150, 50)) 
     .setColorForeground(color(170, 200, 0)) 
     .setColorValue(color(255, 0, 255)) 
     .setColorActive(color(119, 0, 0))  
     .setFont(font)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
 
   controlP5.addButton("open_file")
     .setPosition                                    (330,296)
     .setSize                             (140,   20)
     .setId(5)
     .setCaptionLabel("open file")
    .setColorBackground(color(130, 100, 0))
    .setColorForeground(color(200, 180, 0))
    .setColorValue(color(255, 255, 255)) 
    .setColorActive(color(119, 0, 0)) 
     .setFont(font)
     .getCaptionLabel().align(CENTER,CENTER)
     ;

   controlP5.addButton("Exit")
     .setPosition                                     (400,465)
     .setSize                              (80,   20)
     .setId(5)
     .setColorBackground(color(119, 0, 0)) 
     .setColorForeground(color(220, 0, 0)) 
     .setColorValue(color(255, 255, 255)) 
     .setColorActive(color(119, 0, 0))  
     .setFont(font)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
  

}

public void Clear()      {  console.clear(); }

public void Send()       { String Comand1 =  controlP5.get(Textfield.class,"console")
                           .getText();       
                            port.write(Comand1);
                         }

void Exit()  { exit();   println(" Program Exit "); }

//void las_1()        { port.write( "M3\n");  }
void las_0()        { port.write( "M5\n");  }

void s20()          { port.write("S10\n");  }
void s50()          { port.write("S50\n");  }
void s255()         { port.write("S255\n"); }

void f1()           { port.write("F7000\n"); }
void f10()          { port.write("F5000\n"); }
void f200()         { port.write("F1\n");   }

void home()         { port.write("G28\n");  }

void sel_port()     { selectSerialPort();   }


void open_file()   {  gcode = null; i = 0;
                      File file = null; 
                      println("Loading file...");
                      selectInput("Select a file to process:", "fileSelected", file);
                   }


void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    gcode = loadStrings(selection.getAbsolutePath());
    if (gcode == null) return;
    streaming = true;
    stream();
  }
}

void stream()
{
  if (!streaming) return;
  
  while (true) {
    if (i == gcode.length) {
      streaming = false;
      return;
    }
    
    if (gcode[i].trim().length() == 0) i++;
    else break;
  }
  println(gcode[i]);
  port.write(gcode[i] + '\n');
  i++;  
}

void serialEvent(Serial p)
{
  String s = p.readStringUntil('\n');
  println(s.trim());

  if (s.trim().startsWith("ok")) stream();
  if (s.trim().startsWith("error")) stream(); // XXX: really?

  String[] list = split(s,':');
     testString = trim(list[0]);
     if (list.length != 3) return;
     x_val  = (float(list[0]));
     y_val  = (float(list[1]));          
     l_val  = (float(list[2]));
}


void draw()
{ 
 // x_val = x_val/10;
 // y_val = y_val/10;
  
  background(0);  
/*
      strokeWeight(2);
   stroke(0,0,150);
   fill(0,0,10);  
   rect               (10, 10, 210, 400);
   fill(255);
   textSize(10);
   text ("", 10, 10, 210, 400);
*/
  
  // X wert_____________x___y____w____h___                                 
  fill(0,51,51); 
  noStroke(); 
  rect               (330, 20, 140, 30); 
 
  textAlign(CORNER); 
  textSize(30); 
  fill(255);
    textSize(25);
  text (" X  "+x_val, 330, 21, 150, 30);

// Y wert_______________________________ 
  fill(0,51,51); 
  noStroke(); 
  rect               (330, 70, 140, 30); 
  
  textAlign(CORNER); 
  textSize(30); 
  fill(255); 
    textSize(25);
  text (" Y  "+y_val, 330, 71, 150, 30);  
  
// fill(255);
// Port
 textSize(10);
 fill(0,230,255);
 text("Connected to: " + portname, 12, 500);


// Draw printed value

float x_c = 290;
float y_c = 290;

x_c = x_val*2.5;
y_c = y_val*2.5;




 strokeWeight(1);
 stroke(0, 200,100);
 fill(100,100,100);
 rect               (15, 15, 300, 300); 

 noStroke();
if (l_val==0) fill(255, 255,0);
else
if (l_val==1) fill(255, 0,0);
 ellipse( 290-x_c, 290-y_c, 5, 5);
 
//stroke(255, 255,0);
//line(290, 290, x_c, y_c);
 
}
