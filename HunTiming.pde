import ddf.minim.*;
import processing.net.*;
import pathfinder.*;

//Graph
//GraphNode[]
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
boolean isAllImagesLoaded, isMainPlayer, isKeyReleased, isErrorMsg, isEnterPressed,
movingLeft, movingRight, movingUp, movingDown; // isMainPlayer for the client who update bots, when plays solo or host the game
int sceneNumber, serverPort, time2host, time2Check, timer, playerAmount, playerAmount_maxPerTeam, frameR, frameC, wwCount;
byte map_version, map_path_value, map_wall_value, map_tower_value, map_spawnTeam1_value, map_spawnTeam2_value;
byte[] px;
IntList tower_px;

void setup()
{
  size(1064, 630);
  frameRate(30);
  mainFont = createFont("Arial", 20, true);
  textFont(mainFont);
  textAlign(CENTER, TOP);
  background(0);
  stroke(255);
  text("Loading...", width * 0.5, height * 0.4);
  
  map_path_value = 0;
  map_wall_value = 1;
  map_tower_value = 2;
  map_spawnTeam1_value = 3;
  map_spawnTeam2_value = 4;
  sceneNumber = time2Check = playerAmount = time2host
  = wwCount = frameR = frameC = 0;
  timer = 1;
  playerAmount_maxPerTeam = 5;
  serverPort = 4233;
  isKeyReleased = true;
  isAllImagesLoaded = isMainPlayer = isErrorMsg = isEnterPressed
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
  tower_px = new IntList();
  scene_menu = new Scene(0, background_menuSene);
  scene_prepa = new Scene(1, background_prepaSene);
  scene_score = new Scene(3, background_scoreSene);
  minim = new Minim(this);
  sound_music = minim.loadFile(audioFolderName + "\\sound_music.mp3");
  sound_switch = minim.loadSample(audioFolderName + "\\sound_switch.mp3");
  sound_music.setGain(-20.0);
  sound_music.loop();
}

void draw() 
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

boolean checkLoadedImages()
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

void receiveServerData()
{
  String[] serverRawDataPerClients;
  
  if (myClient != null && myClient.available() > 0)
  {
    serverInput = myClient.readString();
    
    //println("Data in Client : " + serverInput);
    
    serverRawDataPerClients = split(serverInput, '!');
    serverData = new String[serverRawDataPerClients.length][];
    for (int i = 0, c = serverRawDataPerClients.length; i < c; i++)
    {
      serverData[i] = splitTokens(serverRawDataPerClients[i]);
    }
  }
}

String writeString(String s, int maxChar)
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

void keyPressed()
{  
  if (key == CODED)
  {
    if (keyCode == LEFT)          movingLeft = true;
    else if (keyCode == RIGHT)    movingRight = true;
    else if (keyCode == UP)       movingUp = true;
    else if (keyCode == DOWN)     movingDown = true;
  }
}

void keyReleased()
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

boolean isButtonClicked(int[] AABB)
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

boolean checkCollision(int[] box1, int[] box2)
{
  if ( (box2[0] >= box1[0] + box1[2])
  || (box2[0] + box2[2] <= box1[0])
  || (box2[1] >= box1[1] + box1[3])
  || (box2[1] + box2[3] <= box1[1]) )
    return false; 
  else
    return true; 
}

PImage[] imageCut(PImage imageSrc)
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

void createClient()
{
  if (isMainPlayer)
  {
    if (time2host > 90)
    {
      time2host = 0;
      myClient = new Client(this, ipAdress, serverPort);
      sceneNumber = 1;
    }
    else
    {
      time2host++;
      text("Loading...", width * 0.5, 450);
    }
  }
  else
  {
    if (myClient != null)
    {
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
        text("Loading...", width * 0.5, 450);
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
      text("Error : IP not available", width * 0.5, 450);
      fill(255);
    }
    if (isEnterPressed)
    {
      isEnterPressed = false;
      myClient = new Client(this, ipAdress, serverPort);
    }
    text("Saisir l'IP : " + ipAdress, width * 0.5, 400);
    ipAdress = writeString(ipAdress, 15);
  }
}

void selectMap(File mapFile)
{  
  if (mapFile != null)
  {
    mapURL = mapFile.getAbsolutePath();
    mapName = mapURL.substring(mapURL.indexOf("maps")+5, mapURL.indexOf(".")); // getRelativePath
    myClient.write("map " + mapName + "!");
  }
}

void go2TheGameScene()
{
  mapURL = mapsFolderName + mapName + ".png"; // attention! à changer pour permettre de charger plusieurs map différentes (info à envoyer par le serveur depuis la scène précédente)
  map_gameScene = loadImage(mapURL);
  map_dataFileName = mapName + "_data.dat";
  px = loadBytes(mapsFolderName + map_dataFileName);
  scene_game = new Scene(2, map_gameScene);
  sceneNumber = 2;
}

void resetGame()
{
  players.clear();
  tower_px.clear();
  scene_prepa = new Scene(1, background_prepaSene);
  scene_score = new Scene(3, background_scoreSene);
  scene_game = null;
  playerAmount = 0;
  sceneNumber = 1;
}

