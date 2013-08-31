import processing.net.*;

Server myServer;
Client someClient;
int serverPort;

void setup()
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


void draw()
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

