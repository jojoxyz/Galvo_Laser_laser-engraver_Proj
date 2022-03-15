/*     
       1x   Arduino MEGA 2560 
       1x   DAC     MCP4822 , 12 bit, 2x Gain
           
            Arduino Pin 53              ss    / CS     ( dac pin 2 )
            Arduino Pin 51              MOSI  / SDI    ( dac pin 4 )           _____
            Arduino Pin 52              CLK   / SCK    ( dac pin 3 )        1-|  °  |-8
            Arduino Pin 48              LATCH / LDAC   ( dac pin 5 )        2-|     |-7
                              Miror X   OutA           ( dac pin 8 )        3-|     |-6
                              Miror Y   OutB           ( dac pin 6 )        4-|_____|-5
            Arduino Pin +5V             VDD            ( dac pin 1 )          
            Arduino Pin GND             VSS            ( dac pin 7 )


//*************** Voltage **********************************************************************
//*************** We define an int variable to store the voltage in mV *************************
//*************** 100 = 100mV = 0.1V ***********************************************************

               
             1       mm       46.937088
            44.33893 mm     2115.901611

               
                12,5°'         12,5°
                          .
                         /|\
                        / | \
                       /  |  \
                      /   |   \
                     /    |    \
                    /     |     \
                   /      |      \
               c' /       | b'    \  c
                 /        |        \
                /         |         \ 
               /  225.5 b |          \
              /           |           \
             /            |            \
            /      a'     |      a      \
           /______________|______________\
                                 50
 X100mm=4096mV      X=50mm=2048 mV         X0mm=0mV
               
                          0°
  
   x_mV = tan( x_mm / high) * ((4096 * 14.4) / ( 2 * 3.1415926535897932384626433832795 ));  
                                                                             
                                                                             maked by @JoJo 
__G-Code Commands____________________________________________________________________________
G00, G01, G28, M3, M5, S, F, 
                                                                                 
*/

#include <gcode.h>
#include <MCP48xx.h>
#include"MapFloat.h"


MCP4822 dac(53);               // CS Pin 10

#define LDAC    48             // LDAC Pin
#define Laser   44             // (8) Laser Pin PWM
#define mVs 1                  // Stepp  to mV Up / Down

int   Laser_val   =    20 ;    // Laser pover  0-255      

float F_speed     =     1 ;
int        lo     =     0 ;

float    high     = 225.5 ;     // b  Distance of the mirror from the worktop mm

float   x_max     = 100.0 ;     // a*2 X max distance mm
float  x_half     =  50.0 ;     // a  half distance X mm

float   y_max     = 100.0 ;     // a*2 X max distance mm
float  y_half     =  50.0 ;     // a  half distance Y mm

float    x_mV     =     0 ;     // distance X mm in mV
float    y_mV     =     0 ;     // distance Y mm in mV

float     x_i     =     0 ;
float     y_i     =     0 ;

//___________________________________________________________________________

//### Commands
void moviment_0();        // G00
void moviment_1();        // G01
void homing();            // G28
void Las_ON();            // M3  Laser on
void Las_OFF();           // M5  Laser off
void Las_Power();         // S   Laser Power 0-255
void f_speed();           // F   Moving Speed

void gotoLocation();      // Input value conversion mm to mV + korektion tan()

#define NUMCOMMANDS 7
commandscallback commands[NUMCOMMANDS] = { { "G1", moviment_1}, {"G0", moviment_0}, {"G28", homing    }, 
                                           { "M3", Las_ON    }, {"M5", Las_OFF   }, {"S"  , Las_Power },
                                           { "F" , f_speed   }
                                         };
gcode Commands(NUMCOMMANDS,commands);

void setup()
{
    Commands.begin();

    pinMode      ( Laser ,  OUTPUT ) ;
    pinMode      ( LDAC  ,  OUTPUT ) ;
    digitalWrite ( LDAC  ,     LOW ) ;      
   
    dac.init();
    dac.turnOnChannelA();
    dac.turnOnChannelB();

    analogWrite( Laser , 20 );  
    delay(500);  
    analogWrite( Laser , LOW   );
}

void read_line()
{
  if (( x_i == x_mV ) && ( y_i == y_mV ))  Commands.available();  // Interrupts reading the new line
}


void mov()          // Increase and decrease of mV value
{

//#### X
   if ( x_mV  >= x_i ) { x_i +=mVs ; if (x_i >= x_mV) x_i = x_mV; } // Move X ++
                      else  
                       { x_i -=mVs ; if (x_i <= x_mV) x_i = x_mV; } // Move X --

//#### Y
   if ( y_mV  >= y_i ) { y_i +=mVs ; if (y_i >= y_mV) y_i = y_mV; } // Move Y ++
                      else  
                       { y_i -=mVs ; if (y_i <= y_mV) y_i = y_mV; } // Move Y --

   delayMicroseconds(F_speed); 

   dac.setVoltageA(x_i);       
   dac.setVoltageB(y_i);
   dac.updateDAC();
                    
}

void gotoLocation(double x_mm,double y_mm)
{ 
//### X mm to X mV
  if ( x_mm >= 0 && x_mm <= x_half )
    { 
      x_mV = tan( x_mm / high) ;
      x_mV = mapFloat(x_mV, 0, x_half, 0, x_half ); 
    }
else
  if ( x_mm >= x_half && x_mm <= x_max )
    { 
      x_mV = tan( x_mm / high) ;
      x_mV = mapFloat( x_mV, 0, x_max, 0, x_max  ); 
    }

//### Y mm to Y mV
  if ( y_mm >= 0 && y_mm <= y_half )
    { 
      y_mV = tan( y_mm / high) ;
      y_mV = mapFloat(y_mV, 0,  y_half, 0, y_half ); 
    }
else
  if ( y_mm >= y_half && y_mm <= y_max )
    { 
      y_mV = tan( y_mm / high) ;
      y_mV = mapFloat( y_mV, 0, y_max , 0 , y_max ); 
    }

    x_mV =(x_mV  * ((4096 * 14.4) / ( 2 * 3.1415926535897932384626433832795 )));   //X mV to DAC mV 0 - 4096mV
    y_mV =(y_mV  * ((4096 * 14.4) / ( 2 * 3.1415926535897932384626433832795 )));   //Y mV to DAC mV 0 - 4096mV

   Serial.print(x_mm);
   Serial.print(":");
   Serial.print(y_mm);
   Serial.print(":");   
   Serial.println(lo);
}

//### F
void f_speed()
{
    int  F_val ;
    if(Commands.availableValue('F'))       // ADDED parameter Laser Power  F
      F_val = Commands.GetValue('F');
      F_speed = F_val;
      F_speed = map(F_speed, 1, 7000, 7000, 1);
}

//### S
void Las_Power()
{
    int  Las_val ;
    if(Commands.availableValue('S'))       // ADDED parameter Laser Power  S 0-255
      Las_val = Commands.GetValue('S');
      analogWrite( Laser , LOW );
      Laser_val= Las_val;
      analogWrite( Laser , Las_val );      
}

//### M3
void Las_ON() { analogWrite( Laser , Laser_val );  Serial.println("Laser ON");}   // ADDED parameter M3

//### M5
void Las_OFF(){ analogWrite( Laser , LOW );         Serial.println("Laser OFF");} // ADDED parameter M5

//### G28
void homing()
{
    double h_XValue = 0;
    double h_YValue = 0;
      analogWrite( Laser , LOW );
      gotoLocation(h_XValue,h_YValue);
      Serial.println("Home X, Y");

}

//### G00
void moviment_0()
{ 
    double new_0_XValue ;
    double new_0_YValue ;
    if(Commands.availableValue('X'))            // ADDED parameter X in G1
      new_0_XValue = Commands.GetValue('X');
    if(Commands.availableValue('Y'))            // ADDED parameter Y in G1
      new_0_YValue = Commands.GetValue('Y');
      analogWrite( Laser , LOW );
      lo = 0;
      gotoLocation(new_0_XValue,new_0_YValue);
}

//### G01
void moviment_1()
{ 
    double new_1_XValue ;
    double new_1_YValue ;
    if(Commands.availableValue('X'))            // ADDED parameter X in G1
      new_1_XValue = Commands.GetValue('X');
    if(Commands.availableValue('Y'))            // ADDED parameter Y in G1
      new_1_YValue = Commands.GetValue('Y');
      analogWrite( Laser , Laser_val );
      lo = 1;
      gotoLocation(new_1_XValue,new_1_YValue);
}


void loop()
{
  mov();
  read_line();  
} 
