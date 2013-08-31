import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.net.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class HunTiming_Server extends PApplet {



Server myServer;
Client someClient;
int serverPort;

public void setup()
{
  size(155, 140);
  background(0);
  fill(0, 255, 0);
  frameRate(30);
  
  serverPort = 4233;
  myServer = new Server(this, serverPort);
  text("Server is running.\n\nIP : " + myServer.ip() + "\n\nPort : " + serverPort
  + "\n\n\nDon't close this window !", 10, 20);
  
  //if (frame != null) frame.setState(frame.ICONIFIED);
  //if (focused) focused = false;
}


public void draw()
{
  try
  {
    someClient = myServer.available();
    
    if (someClient != null && someClient.available() > 0)
    {
      myServer.write(someClient.readString());
    }
  }
  catch (Exception error)
  {
    println("\n--------------- SERVER ERROR !!! ---------------");
    error.printStackTrace();
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "HunTiming_Server" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
