import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import processing.net.*; 
import pathfinder.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class HunTiming extends PApplet {





Client myClient;
Minim minim;
AudioPlayer sound_music;
AudioSample sound_switch;
Scene scene_menu, scene_prepa, scene_game, scene_score;
Player myPlayer;
ArrayList<Player> players;
PFont mainFont;
PImage map_gameScene, background_menuSene, background_prepaSene, background_scoreSene,
humanFullPictureUp, humanFullPictureDown, humanFullPictureLeft, humanFullPictureRight, humanFullPictureIdle,
werewolfFullPictureUp, werewolfFullPictureDown, werewolfFullPictureLeft, werewolfFullPictureRight, werewolfFullPictureIdle;
PImage[] humanSpriteSheetUp, humanSpriteSheetDown, humanSpriteSheetLeft, humanSpriteSheetRight, humanSpriteSheetIdle,
werewolfSpriteSheetUp, werewolfSpriteSheetDown, werewolfSpriteSheetLeft, werewolfSpriteSheetRight, werewolfSpriteSheetIdle;
String ipAdress, serverInput, serverExeUrl, playerName, mapName, map_dataFileName, mapsFolderName, mapURL, imagesFolderName, audioFolderName;
String serverData[][];
boolean isAllImagesLoaded, isMainPlayer, isKeyReleased, isErrorMsg, isEnterPressed, //willBeMainPlayer?
movingLeft, movingRight, movingUp, movingDown; // isMainPlayer for the client who update bots, when plays solo or host the game
int sceneNumber, serverPort, time2host, time2Check, timer, playerAmount, playerAmount_maxPerTeam, frameR, frameC;
byte map_version, map_path_value, map_wall_value, map_tower_value, map_spawnTeam1_value, map_spawnTeam2_value;
byte[] px;

public void setup()
{
  size(1064, 630);
  frameRate(30);
  mainFont = createFont("Arial", 20, true);
  textFont(mainFont);
  textAlign(CENTER, TOP);
  background(0);
  stroke(255);
  text("Loading...", width * 0.5f, height * 0.4f);
  
  map_path_value = 0;
  map_wall_value = 1;
  map_tower_value = 2;
  map_spawnTeam1_value = 3;
  map_spawnTeam2_value = 4;
  sceneNumber = time2Check = playerAmount = time2host
  = frameR = frameC = 0;
  timer = 1;
  playerAmount_maxPerTeam = 5;
  serverPort = 4233;
  isKeyReleased = true;
  isAllImagesLoaded = isMainPlayer = isErrorMsg = isEnterPressed// = willBeMainPlayer
  = movingLeft = movingRight = movingUp = movingDown = false;
  ipAdress = "localhost";
  serverExeUrl = sketchPath("") + "server\\HunTiming_Server.exe";
  playerName = "";
  mapName = "map_forest";
  map_dataFileName = "map_forest_data";
  imagesFolderName = "\\source\\images\\";
  audioFolderName = "\\source\\audio\\";
  mapsFolderName = imagesFolderName + "maps\\";
  background_menuSene = requestImage(imagesFolderName + "bg_menu.png");
  background_prepaSene = requestImage(imagesFolderName + "bg_menu.png");
  background_scoreSene = requestImage(imagesFolderName + "bg_menu.png");
  humanFullPictureUp = requestImage(imagesFolderName + "player_h_up.png");
  humanFullPictureDown = requestImage(imagesFolderName + "player_h_down.png");
  humanFullPictureLeft = requestImage(imagesFolderName + "player_h_left.png");
  humanFullPictureRight = requestImage(imagesFolderName + "player_h_right.png");
  humanFullPictureIdle = requestImage(imagesFolderName + "player_h_idle.png");
  werewolfFullPictureUp = requestImage(imagesFolderName + "player_ww_up.png");
  werewolfFullPictureDown = requestImage(imagesFolderName + "player_ww_down.png");
  werewolfFullPictureLeft = requestImage(imagesFolderName + "player_ww_left.png");
  werewolfFullPictureRight = requestImage(imagesFolderName + "player_ww_right.png");
  werewolfFullPictureIdle = requestImage(imagesFolderName + "player_ww_idle.png");
  players = new ArrayList<Player>();
  scene_menu = new Scene(0, background_menuSene);
  scene_prepa = new Scene(1, background_prepaSene);
  scene_score = new Scene(3, background_scoreSene);
  minim = new Minim(this);
  sound_music = minim.loadFile(audioFolderName + "\\sound_music.mp3");
  sound_switch = minim.loadSample(audioFolderName + "\\sound_switch.mp3");
  sound_music.setGain(-20.0f);
  sound_music.loop();
}

public void draw() 
{
  try
  { 
    if (isAllImagesLoaded || checkLoadedImages())
    {
      receiveServerData();
      
      switch(sceneNumber)
      {
        case 0: 
          scene_menu.update();
          break;
        case 1: 
          scene_prepa.update();
          break;
        case 2: 
          scene_game.update();
        break;
        case 3: 
          scene_score.update();
        break;
      }
    }
  }
  catch (Exception error)
  {
    println("\n/!\\ The whole frame was skipped due to exception error !");
    error.printStackTrace();
  }
}

// -------------------------------------------------------------------------------

public boolean checkLoadedImages()
{
  if ( background_menuSene.width > 0 && background_prepaSene.width > 0
  && humanFullPictureUp.width > 0 && humanFullPictureDown.width > 0
  && humanFullPictureLeft.width > 0 && humanFullPictureRight.width > 0
  && humanFullPictureIdle.width > 0 && werewolfFullPictureUp.width > 0
  && werewolfFullPictureDown.width > 0 && werewolfFullPictureLeft.width > 0
  && werewolfFullPictureRight.width > 0 && werewolfFullPictureIdle.width > 0 )
  {
    humanSpriteSheetUp = imageCut(humanFullPictureUp);
    humanSpriteSheetDown = imageCut(humanFullPictureDown);
    humanSpriteSheetLeft = imageCut(humanFullPictureLeft);
    humanSpriteSheetRight = imageCut(humanFullPictureRight);
    humanSpriteSheetIdle = imageCut(humanFullPictureIdle);
    werewolfSpriteSheetUp = imageCut(werewolfFullPictureUp);
    werewolfSpriteSheetDown = imageCut(werewolfFullPictureDown);
    werewolfSpriteSheetLeft = imageCut(werewolfFullPictureLeft);
    werewolfSpriteSheetRight = imageCut(werewolfFullPictureRight);
    werewolfSpriteSheetIdle = imageCut(werewolfFullPictureIdle);
    isAllImagesLoaded = true;
  }
  else isAllImagesLoaded = false;
  return isAllImagesLoaded;
}

public void receiveServerData()
{
  String[] serverRawDataPerClients;
  
  if (myClient != null && myClient.available() > 0)
  {
    serverInput = myClient.readString();
    
    println("Data in Client : " + serverInput);
    
    serverRawDataPerClients = split(serverInput, '!');
    serverData = new String[serverRawDataPerClients.length][];
    for (int i = 0, c = serverRawDataPerClients.length; i < c; i++)
    {
      serverData[i] = splitTokens(serverRawDataPerClients[i]);
    }
  }
}

public String writeString(String s, int maxChar)
{ 
  if (keyPressed && isKeyReleased)
  {
    isKeyReleased = false;
    isErrorMsg = false;
    if (key == BACKSPACE && s.length() > 0) s = s.substring(0, s.length() - 1);
    if (key != CODED && key != TAB && key != ' ' && key != '!' && s.length() <= maxChar)
    {
      if (key == RETURN || key == ENTER) isEnterPressed = true;
      else if (key != BACKSPACE) s += key;
    }
  }
  return trim(s);
}

public void keyPressed()
{  
  if (key == CODED)
  {
    if (keyCode == LEFT)          movingLeft = true;
    else if (keyCode == RIGHT)    movingRight = true;
    else if (keyCode == UP)       movingUp = true;
    else if (keyCode == DOWN)     movingDown = true;
  }
}

public void keyReleased()
{
  isKeyReleased = true;
  
  if (key == CODED)
  {
    if (keyCode == LEFT)          movingLeft = false;
    else if (keyCode == RIGHT)    movingRight = false;
    else if (keyCode == UP)       movingUp = false;
    else if (keyCode == DOWN)     movingDown = false;
  }
}

public boolean isButtonClicked(int[] AABB)
{
  if (mousePressed && mouseX >= AABB[0] && mouseX < AABB[0] + AABB[2]
  && mouseY >= AABB[1] && mouseY < AABB[1] + AABB[3])
  {
    mousePressed = false;
    return true;
  }
  else
    return false;
}

public boolean checkCollision(int[] box1, int[] box2)
{
  if ( (box2[0] >= box1[0] + box1[2])
  || (box2[0] + box2[2] <= box1[0])
  || (box2[1] >= box1[1] + box1[3])
  || (box2[1] + box2[3] <= box1[1]) )
    return false; 
  else
    return true; 
}

public PImage[] imageCut(PImage imageSrc)
{
  PImage[] pictures;
  pictures = new PImage[4];
  
  for (int i = 0, c = pictures.length; i < c; i++)
  {
    pictures[i] = createImage(32, 32, ARGB);
    pictures[i].loadPixels();
    imageSrc.loadPixels();
     
    for (int i2 = 0, c2 = pictures[i].pixels.length; i2 < c2; i2++)
    {
      pictures[i].pixels[i2] = imageSrc.pixels[i2 + i * (32 * 32)];
    }
    pictures[i].updatePixels();
    imageSrc.updatePixels();
  }
  return pictures;
}

public void createClient()
{
  if (isMainPlayer)
  {
    if (time2host > 90)
    {
      time2host = 0;
      myClient = new Client(this, ipAdress, serverPort);
      //myClient.write("n666 " + playerName + "!");
      sceneNumber = 1;
    }
    else
    {
      time2host++;
      text("Loading...", width * 0.5f, 450);
    }
  }
  else
  {
    if (myClient != null)
    {
      //myClient.write("n666 " + playerName + "!");
      if (serverData != null)
      {
        sceneNumber = 1;
      }
      else if (time2Check > 150)
      {
        time2Check = 0;
        myClient = null;
        isErrorMsg = true;
      }
      else
      {
        time2Check++;
        text("Loading...", width * 0.5f, 450);
      }
    }
    else
    {
      time2Check = 0;
    }
    if (isErrorMsg)
    {
      myClient = null;
      fill (255, 0, 0);
      text("Error : IP not available", width * 0.5f, 450);
      fill(255);
    }
    if (isEnterPressed)
    {
      isEnterPressed = false;
      myClient = new Client(this, ipAdress, serverPort);
    }
    text("Saisir l'IP : " + ipAdress, width * 0.5f, 400);
    ipAdress = writeString(ipAdress, 15);
  }
}

public void selectMap(File mapFile)
{  
  if (mapFile != null)
  {
    mapURL = mapFile.getAbsolutePath();
    mapName = mapURL.substring(mapURL.indexOf("maps")+5, mapURL.indexOf(".")); // getRelativePath
    myClient.write("map " + mapName + "!");
  }
}

public void go2TheGameScene()
{
  mapURL = mapsFolderName + mapName + ".png"; // attention! \u00e0 changer pour permettre de charger plusieurs map diff\u00e9rentes (info \u00e0 envoyer par le serveur depuis la sc\u00e8ne pr\u00e9c\u00e9dente)
  map_gameScene = loadImage(mapURL);
  map_dataFileName = mapName + "_data.dat";
  px = loadBytes(mapsFolderName + map_dataFileName);
  scene_game = new Scene(2, map_gameScene);
  sceneNumber = 2;
}


class Player
{
  int axeX, axeY, playerPixelPosition, posX2CenterTheText;
  int[] box;
  String name, animationName, team, previousTeam;
  float x, y, speed, repulsionStrength;
  boolean isBot, canSwitch; //, canCollide
  byte w, h;
  
  Player (String name, boolean isBot, String team)
  {
    this.animationName = "d";
    this.name = name;
    this.isBot = isBot;
    this.team = team;
    this.previousTeam = team;
    this.speed = 6;
    this.repulsionStrength = this.speed;
    this.w = 32;
    this.h = 32;
    if (team.equals("1"))
    {
      this.x = 100;
      this.y = 100;
    }
    else
    {
      this.x = 400;
      this.y = 100;
    }
    this.box = new int[] { PApplet.parseInt(this.x), PApplet.parseInt(this.y), this.w, this.h };
    this.playerPixelPosition = 10000;
    this.posX2CenterTheText = PApplet.parseInt(this.w * 0.5f);
    this.canSwitch = true;
    //this.canCollide = true;
  }
  
///----------------------------------------------------------------------
  
  public void update4Server()
  {
     //---Gere l'udate des deplacements de myPlayer  
    if (!this.isBot) // si c'est un joueur
    {
      this.axeX = this.axeY = 0;
      if (movingLeft)       this.axeX = -1;
      if (movingRight)      this.axeX = 1;
      if (movingUp)         this.axeY = -1;
      if (movingDown)       this.axeY = 1;
      
      if (this.team != this.previousTeam) // d\u00e9tection d'un changement de team, pour jouer un son correspondant, \u00e0 faire uniqement c\u00f4t\u00e9 client!
      {
        this.previousTeam = this.team;
        //this.canCollide = false;
        sound_switch.trigger();
      }
    }
    //else // si c'est un bot (pour plus tard)
    
    if (timer == 0)
    {
      if (this.canSwitch)
      {
        this.canSwitch = false;
        if (this.team.equals("1")) this.team = "2";
        else this.team = "1";
      }
    }
    else this.canSwitch = true;
    
    
    if (this.axeX != 0 && this.axeY != 0)
    {
      this.x += this.axeX * (this.speed * 0.7f);
      this.y += this.axeY * (this.speed * 0.7f);
      this.repulsionStrength = this.speed * 2;
    }
    else
    {
      this.x += this.axeX * this.speed;
      this.y += this.axeY * this.speed;
      this.repulsionStrength = this.speed;
    }
    
    
    this.playerPixelPosition = (PApplet.parseInt(this.y) + PApplet.parseInt(this.h * 0.5f)) * width + PApplet.parseInt(this.x) + PApplet.parseInt(this.w * 0.5f) + 1; // pour les collisions
    
    if (this.y <= 5) this.y += this.repulsionStrength;
    else if (this.y + this.h + 5 >= height) this.y -= this.speed * 3;
    else if (this.x <= 5) this.x += this.repulsionStrength;
    else if (this.x + this.w + 5 >= width) this.x -= this.repulsionStrength;
    
    if (px[this.playerPixelPosition - PApplet.parseInt(this.h * 0.5f * width)] == map_wall_value) //
    {
      this.y += this.repulsionStrength;
    }
    else if (px[this.playerPixelPosition + PApplet.parseInt(this.h * 0.5f * width)] == map_wall_value) //
    {
      this.y -= this.repulsionStrength;
    }
    else if (px[this.playerPixelPosition - PApplet.parseInt(this.w * 0.5f)] == map_wall_value) //
    {
      this.x += this.repulsionStrength;
    }
    else if (px[this.playerPixelPosition + PApplet.parseInt(this.w * 0.5f)] == map_wall_value) //
    {
      this.x -= this.repulsionStrength;
    }
  
    //---Gere l'update des animations de myPlayer
    if (this.axeY == -1)        this.animationName = "u";
    else if (this.axeY == 1)    this.animationName = "d";
    else if (this.axeX == -1)   this.animationName = "l";
    else if (this.axeX == 1)    this.animationName = "r";
    else                        this.animationName = "i";
  }
  
///----------------------------------------------------------------------  
  
  public void clientUpdate()
  {
    //---Gere le rendu des animations en fonction de l'\u00e9quipe!!
    
    this.box[0] = PApplet.parseInt(this.x);
    this.box[1] = PApplet.parseInt(this.y);
    
    if (this.team.equals("1"))
    {
      if (animationName.equals("u"))            image(humanSpriteSheetUp[frameC], this.x, this.y);
      else if (animationName.equals("d"))       image(humanSpriteSheetDown[frameC], this.x, this.y);
      else if (animationName.equals("l"))       image(humanSpriteSheetLeft[frameC], this.x, this.y);
      else if (animationName.equals("r"))       image(humanSpriteSheetRight[frameC], this.x, this.y);
      else                                      image(humanSpriteSheetIdle[frameC], this.x, this.y);
    }
    else
    {
      if (animationName.equals("u"))            image(werewolfSpriteSheetUp[frameC], this.x, this.y);
      else if (animationName.equals("d"))       image(werewolfSpriteSheetDown[frameC], this.x, this.y);
      else if (animationName.equals("l"))       image(werewolfSpriteSheetLeft[frameC], this.x, this.y);
      else if (animationName.equals("r"))       image(werewolfSpriteSheetRight[frameC], this.x, this.y);
      else                                      image(werewolfSpriteSheetIdle[frameC], this.x, this.y);
    }
    
    fill(255, 127, 0);
    text (this.name, this.x + this.posX2CenterTheText, this.y - 23);
  }
  
  
}

class Scene
{
  int idNumber, state, team_1_spawn_x, team_1_spawn_y, team_2_spawn_x, team_2_spawn_y;
  PImage background;
  int[] button_AABB_1, button_AABB_2, button_AABB_3;
  String button_text_1, button_text_2, button_text_3;
  StringList reservedName;
  boolean required_1, required_2;
  
  Scene (int id, PImage sceneBg)
  {
    this.idNumber = id;
    this.state = 0;
    this.background = sceneBg;
    this.required_1 = this.required_2 = false;
    this.reservedName = new StringList();
    
    this.team_1_spawn_x = this.team_1_spawn_y
    = this.team_2_spawn_x = this.team_2_spawn_y = 0;
   
    if (id == 0)
    {
      this.button_AABB_1 = new int[] { 400, 350, 90, 30 };
      this.button_AABB_2 = new int[] { 550, 350, 90, 30 };
      this.button_text_1 = "Solo";
      this.button_text_2 = "Multi";
    }
    else if (id == 1)
    {
      this.button_AABB_1 = new int[] { PApplet.parseInt(width * 0.35f), PApplet.parseInt(height * 0.5f), 150, 30 };
      this.button_AABB_2 = new int[] { PApplet.parseInt(width * 0.75f), PApplet.parseInt(height * 0.7f), 150, 30 };
      this.button_AABB_3 = new int[] { PApplet.parseInt(width * 0.75f), PApplet.parseInt(height * 0.8f), 150, 30 };
      this.button_text_1 = "Map";
      this.button_text_2 = "Launch";
    }
  }
  
  public void update ()
  {
    image(this.background, 0, 0);
    switch (this.idNumber)
    {
      // --------------------------------------------------------------------------------
      case 0:
        switch (this.state)
        {
          case 0:
            fill(64);
            rect(this.button_AABB_1[0], this.button_AABB_1[1], this.button_AABB_1[2], this.button_AABB_1[3], 7);
            rect(this.button_AABB_2[0], this.button_AABB_2[1], this.button_AABB_2[2], this.button_AABB_2[3], 7);
            fill(255);
            text(this.button_text_1, this.button_AABB_1[0] + this.button_AABB_1[2] * 0.5f, this.button_AABB_1[1] + 3);
            text(this.button_text_2, this.button_AABB_2[0] + this.button_AABB_2[2] * 0.5f, this.button_AABB_2[1] + 3);
            
            if (isButtonClicked(this.button_AABB_1)) // if "solo"
            {
              isMainPlayer = true;
              players.add(new Player("", false, "1"));
              playerAmount++;
              sceneNumber = 1;
            }
            else if (isButtonClicked(this.button_AABB_2)) // if "multi"
            {
              this.state = 1;
              this.button_text_1 = "Join";
              this.button_text_2 = "Host";
            }
          break;
          case 1: // if "multi : "host" or "join"
            if (isButtonClicked(this.button_AABB_1) && playerName.length() > 1) // "join"
            {
              isMainPlayer = false;
              this.state = 2;
            }
            else if (isButtonClicked(this.button_AABB_2) && playerName.length() > 1) // "host"
            {
              isMainPlayer = true;
              ipAdress = Server.ip();
              open(serverExeUrl);
              this.state = 2;
            }
            else
            {
              fill(64);
              rect(this.button_AABB_1[0], this.button_AABB_1[1], this.button_AABB_1[2], this.button_AABB_1[3], 7);
              rect(this.button_AABB_2[0], this.button_AABB_2[1], this.button_AABB_2[2], this.button_AABB_2[3], 7);
              fill(255);
              text(this.button_text_1, this.button_AABB_1[0] + this.button_AABB_1[2] * 0.5f, this.button_AABB_1[1] + 3);
              text(this.button_text_2, this.button_AABB_2[0] + this.button_AABB_2[2] * 0.5f, this.button_AABB_2[1] + 3);
              text("Pseudo : " + playerName, this.button_AABB_1[0] + 100, this.button_AABB_1[1] + 100);
              playerName = writeString(playerName, 9);
            }
          break;
          case 2:
            createClient();
          break;
        }
      break;
      // --------------------------------------------------------------------------------
      case 1:
        if (myClient != null && second() % 2 == 0)
        {
          myClient.write("n666 " + playerName + "!pampt " + playerAmount_maxPerTeam + "!");
        }
        fill(255);
        text("Map : " + mapName, width * 0.81f, height * 0.6f);
        if (isMainPlayer)
        {
          fill(64);// les boutons "launch" et "map"
          rect(this.button_AABB_2[0], this.button_AABB_2[1], this.button_AABB_2[2], this.button_AABB_2[3], 7);
          rect(this.button_AABB_3[0], this.button_AABB_3[1], this.button_AABB_3[2], this.button_AABB_3[3], 7);
          fill(255);
          text(this.button_text_1, this.button_AABB_2[0] + this.button_AABB_2[2] * 0.5f, this.button_AABB_2[1] + 3);
          text(this.button_text_2, this.button_AABB_3[0] + this.button_AABB_3[2] * 0.5f, this.button_AABB_3[1] + 3);
          
          playerAmount_maxPerTeam = PApplet.parseInt(writeString(nfc(playerAmount_maxPerTeam), 2));
          fill(128, 128, 255);
          text("Players per team : " + playerAmount_maxPerTeam, width * 0.81f, height * 0.5f);
          
          if (isButtonClicked(this.button_AABB_2)) // button "map"
          {
            this.required_1 = true;
            selectInput("Select a map to play : ", "selectMap");
          }
          else if (isButtonClicked(this.button_AABB_3)) // button "Launch"
          {
            if (myClient != null) myClient.write("go go!");
            else this.required_2 = true; // if "solo" mode
          }
        }
        fill(0); // draw the array
        for (int i = 0; i < playerAmount_maxPerTeam; i++)
        {
          int x = this.button_AABB_1[0];
          int y = this.button_AABB_1[1] + i * (this.button_AABB_1[3]);
          rect( x, y, this.button_AABB_1[2], this.button_AABB_1[3], 7);
          rect( x + this.button_AABB_1[2], y, this.button_AABB_1[2], this.button_AABB_1[3], 7);
        }
        // draw the text
        for (int i = 0, c = playerAmount_maxPerTeam * 2;  i < c; i++)
        {
          int x = this.button_AABB_1[0] + PApplet.parseInt(this.button_AABB_1[2] * 0.5f);
          int y = 3 + this.button_AABB_1[1] + i * PApplet.parseInt(this.button_AABB_1[3] * 0.5f);
    
          if (players.size() > i)
          {
            fill(255); 
            if (i % 2 == 1) text(players.get(i).name, x + this.button_AABB_1[2], y - PApplet.parseInt(this.button_AABB_1[3] * 0.5f));
            else text(players.get(i).name, x, y);
          }
          else
          {
            fill(0, 255, 0);
            if (i % 2 == 1) text("bot", x + this.button_AABB_1[2], y - PApplet.parseInt(this.button_AABB_1[3] * 0.5f));
            else text("bot", x, y);
          }
        }
        
        if (serverData != null && serverData.length > 0) //ajout de nouveaux joueurs
        {
          String clienTeam;
          if (players.size() % 2 == 0) clienTeam = "1";
          else clienTeam = "2";
          
          for (int i1 = 0, c1 = serverData.length; i1 < c1; i1++)
          {
            if (players.size() == 0)
            {
              if (serverData[i1][0].equals("n666"))
              {
                players.add(new Player(serverData[i1][1], false, clienTeam));
                reservedName.append(serverData[i1][1]);
                playerAmount++;
              }
            }
            else
            {
              
            if (serverData[i1].length == 2)
            {
              if (serverData[i1][0].equals("n666")
              && !reservedName.hasValue(serverData[i1][1]))
              {
                players.add(new Player(serverData[i1][1], false, clienTeam));
                reservedName.append(serverData[i1][1]);
                playerAmount++;
              }
              if (serverData[i1][0].equals("pampt") && !isMainPlayer)
              {
                playerAmount_maxPerTeam = PApplet.parseInt(serverData[i1][1]);
              }
              if (serverData[i1][0].equals("map") && !isMainPlayer)
              {
                mapName = serverData[i1][1];
              }
              if (serverData[i1][0].equals("go"))
              {
                this.required_2 = true;
              }
                
              }
            }
          }
        }
        if (this.required_2)
        {
          String t;
          for (int i = 0, c = playerAmount_maxPerTeam * 2;  i < c; i++)
          {
            if (players.size() % 2 == 0) t = "1";
            else t = "2";
            if (players.size() <= i)
            {
              players.add(new Player("bot" + i, true, t)); // ajout de bots
              playerAmount++;
            }
          }
          go2TheGameScene();
        }
      break;
      // --------------------------------------------------------------------------------
      case 2:
        
        if (frameR >= 4) frameC = (frameC +1) % 4;
        frameR = (frameR + 1) % 5;
        
        stroke(255);
        fill(0);
        text(timer, width * 0.5f, 20);
        /*
        if (this.timer == 0)
        {
          if (!this.required_1)
          {
            this.required_1 = true;
            for (int i = 0; i < playerAmount; i++)
            {
              if (players.get(i).team.equals("1")) players.get(i).team = "2";
              else players.get(i).team = "1";
            }
          }
        }
        else this.required_1 = false;
        */
        switch (this.state)
        {
          case 0:
            for (int i = 0, c = px.length; i < c; i++)
            {
              if (px[i] == map_spawnTeam1_value && this.team_1_spawn_x == 0)
              {
                this.team_1_spawn_x = i % width;
                this.team_1_spawn_y = floor(i / width);
              }
              else if (px[i] == map_spawnTeam2_value && this.team_2_spawn_x == 0)
              {
                this.team_2_spawn_x = i % width;
                this.team_2_spawn_y = floor(i / width);
              }
            }
            for (int i = 0; i < playerAmount; i++)
            {
              if (players.get(i).team.equals("1"))
              {
                players.get(i).x = this.team_1_spawn_x;
                players.get(i).y = this.team_1_spawn_y;
              }
              else
              {
                players.get(i).x = this.team_2_spawn_x;
                players.get(i).y = this.team_2_spawn_y;
              }
              if (players.get(i).name.equals(playerName))
              {
                //println("-----------------------------> yep!");
                myPlayer = players.get(i);
              }
              /*if (players.get(i).isBot)
              {
                players.get(i).update4Server();
              }*/
            }
            this.state = 1;
          break;
          // ------------------------------------ //
          case 1:
            myPlayer.update4Server();
            
            if (myPlayer.team.equals("1")) fill(255, 200);
            else fill(255, 128, 128, 200);
            noStroke();
            ellipse(myPlayer.x + myPlayer.posX2CenterTheText, myPlayer.y + myPlayer.h, myPlayer.w, 20);
            
            if (myClient != null)
            {
              myClient.write("u " + myPlayer.name + " " + myPlayer.team + " " + myPlayer.animationName + " "
              + myPlayer.x + " " + myPlayer.y + "!");
            }
            else // if "solo" mode
            {
              for (int i = 0, c = players.size(); i < c; i++)
              {
                //players.get(i).clientUpdate();
                //players.get(i).update4Server();
                //stroke(0,255,0);
                //rect(players.get(i).box[0], players.get(i).box[1], players.get(i).box[2], players.get(i).box[3]);
                players.get(i).clientUpdate();
                if (myPlayer.team.equals("1") && players.get(i).team.equals("2")
                && myPlayer.canSwitch && checkCollision(myPlayer.box, players.get(i).box))
                {
                  println("aaaaaaaaaaaaaaaaarrrrrrrrrggggg!!!");
                  myPlayer.team = "2";
                }
              }
            }
            
            // ------------------------------------ //
            
            if (isMainPlayer)
            {
              if (myClient != null) myClient.write("t " + second() % 10 + "!");
              else timer = second() % 10;
              
              for (int i1 = 0, c1 = players.size(); i1 < c1; i1++)
              {
                if (players.get(i1).isBot)
                {
                  //players.get(i1).clientUpdate();
                  
                  for (int i2 = 0, c2 = players.size(); i2 < c2; i2++)
                  {
                    if (players.get(i1).team.equals("1") && players.get(i2).team.equals("2") //&& myPlayer.canCollide
                    && myPlayer.canSwitch && checkCollision(players.get(i1).box, players.get(i2).box))
                    {
                      players.get(i1).team = "2";
                    }
                  }
                  
                  players.get(i1).update4Server();
                  
                  if (myClient != null)
                  {
                    myClient.write("u " + players.get(i1).name + " " + players.get(i1).team + " "
                    + players.get(i1).animationName + " " + players.get(i1).x + " " + players.get(i1).y + "!");
                  }
                }
              }
            }
            
            // ------------------------------------ //
            
            if (serverData != null && serverData.length > 0)
            {
              for (int i1 = 0, c1 = serverData.length; i1 < c1; i1++)
              {
                if (serverData[i1].length == 6 && serverData[i1][0].equals("u"))
                {
                  for (int i2 = 0, c2 = players.size(); i2 < c2; i2++)
                  {
                    if (serverData[i1][1].equals(players.get(i2).name))
                    {
                      if (!serverData[i1][1].equals(myPlayer.name))
                      {
                        if (!isMainPlayer || (isMainPlayer && !players.get(i2).isBot))
                        {
                          players.get(i2).team = serverData[i1][2];
                          players.get(i2).animationName = serverData[i1][3];
                          players.get(i2).x = PApplet.parseFloat(serverData[i1][4]);
                          players.get(i2).y = PApplet.parseFloat(serverData[i1][5]);
                        }
                      }
                      //stroke(0,255,0);
                      //rect(players.get(i2).box[0], players.get(i2).box[1], players.get(i2).box[2], players.get(i2).box[3]);
                      //players.get(i2).clientUpdate();
                    }
                  }
                }
                else if (serverData[i1].length > 0 && serverData[i1][0].equals("t"))
                {
                  timer = PApplet.parseInt(serverData[i1][1]);
                }
              }
            }
            
            for (int i = 0, c = players.size(); i < c; i++)
            {
              players.get(i).clientUpdate();
              if (myPlayer.team.equals("1") && players.get(i).team.equals("2") //&& myPlayer.canCollide
              && myPlayer.canSwitch && checkCollision(myPlayer.box, players.get(i).box))
              {
                myPlayer.team = "2";
              }
            }
            
          break;
          
          case 2:
          
          break;
          
          case 3:
          
          break;
        }
      break;
      
      case 3:
        switch (this.state)
        {
          case 0:
          
          break;
          
          case 1:
          
          break;
          
          case 2:
          
          break;
          
          case 3:
          
          break;
        }
      break;
    }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "HunTiming" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
