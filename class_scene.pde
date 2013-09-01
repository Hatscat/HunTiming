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
      this.button_AABB_1 = new int[] { int(width * 0.35), int(height * 0.5), 150, 30 };
      this.button_AABB_2 = new int[] { int(width * 0.75), int(height * 0.7), 150, 30 };
      this.button_AABB_3 = new int[] { int(width * 0.75), int(height * 0.8), 150, 30 };
      this.button_text_1 = "Map";
      this.button_text_2 = "Launch";
    }
    else if (id == 3)
    {
      this.button_AABB_1 = new int[] { int(width * 0.3), int(height * 0.4), 150, 30 };
      this.button_AABB_2 = new int[] { int(width * 0.8), int(height * 0.85), 150, 30 };
      this.button_text_1 = "Play again";
    }
  }
  
  void update ()
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
            text(this.button_text_1, this.button_AABB_1[0] + this.button_AABB_1[2] * 0.5, this.button_AABB_1[1] + 3);
            text(this.button_text_2, this.button_AABB_2[0] + this.button_AABB_2[2] * 0.5, this.button_AABB_2[1] + 3);
            
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
              text(this.button_text_1, this.button_AABB_1[0] + this.button_AABB_1[2] * 0.5, this.button_AABB_1[1] + 3);
              text(this.button_text_2, this.button_AABB_2[0] + this.button_AABB_2[2] * 0.5, this.button_AABB_2[1] + 3);
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
        if (myClient != null && second() % 2 == 0) // send data
        {
          myClient.write("n666 " + playerName + "!pampt " + playerAmount_maxPerTeam + "!");
        }
        fill(255);
        text("Map : " + mapName, width * 0.81, height * 0.6);
        if (isMainPlayer)
        {
          fill(64);// les boutons "launch" et "map"
          rect(this.button_AABB_2[0], this.button_AABB_2[1], this.button_AABB_2[2], this.button_AABB_2[3], 7);
          rect(this.button_AABB_3[0], this.button_AABB_3[1], this.button_AABB_3[2], this.button_AABB_3[3], 7);
          fill(255);
          text(this.button_text_1, this.button_AABB_2[0] + this.button_AABB_2[2] * 0.5, this.button_AABB_2[1] + 3);
          text(this.button_text_2, this.button_AABB_3[0] + this.button_AABB_3[2] * 0.5, this.button_AABB_3[1] + 3);
          
          playerAmount_maxPerTeam = int(writeString(nfc(playerAmount_maxPerTeam), 2));
          fill(128, 128, 255);
          text("Players per team : " + playerAmount_maxPerTeam, width * 0.81, height * 0.5);
          
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
          int x = this.button_AABB_1[0] + int(this.button_AABB_1[2] * 0.5);
          int y = 3 + this.button_AABB_1[1] + i * int(this.button_AABB_1[3] * 0.5);
    
          if (players.size() > i)
          {
            fill(255); 
            if (i % 2 == 1) text(players.get(i).name, x + this.button_AABB_1[2], y - int(this.button_AABB_1[3] * 0.5));
            else text(players.get(i).name, x, y);
          }
          else
          {
            fill(0, 255, 0);
            if (i % 2 == 1) text("bot", x + this.button_AABB_1[2], y - int(this.button_AABB_1[3] * 0.5));
            else text("bot", x, y);
          }
        }
        
        if (serverData != null && serverData.length > 0) // receive data = ajout de nouveaux joueurs
        {
          String clienTeam;
          if (players.size() % 2 == 0) clienTeam = "1";
          else clienTeam = "2";
          
          for (int i1 = 0, c1 = serverData.length; i1 < c1; i1++)
          {
            if (players.size() == 0)
            {
              if (serverData[i1].length > 1 && serverData[i1][0].equals("n666"))
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
                if (serverData[i1].length > 1 && serverData[i1][0].equals("n666")
                && !reservedName.hasValue(serverData[i1][1]))
                {
                  players.add(new Player(serverData[i1][1], false, clienTeam));
                  reservedName.append(serverData[i1][1]);
                  playerAmount++;
                }
                if (serverData[i1][0].equals("pampt") && !isMainPlayer)
                {
                  playerAmount_maxPerTeam = int(serverData[i1][1]);
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
        fill(200, 0, 255);
        textSize(80);
        text(timer, width * 0.5 - textWidth(nfc(timer)) * 0.75, 0);
        textSize(20);
        
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
              else if (px[i] == map_tower_value)
              {
                tower_px.append(i);
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
            
            for (int i = 0, c = players.size(); i < c; i++)
            {
              players.get(i).clientUpdate();
              
              if (myPlayer.canSwitch && checkCollision(myPlayer.box, players.get(i).box))
              {
                if (myPlayer.team.equals("1") && players.get(i).team.equals("2"))
                {
                  myPlayer.team = "2";
                  myPlayer.deathCount++;
                }
                else if (myPlayer.team.equals("2") && players.get(i).team.equals("1"))
                {
                  myPlayer.killCount++;
                }
              }
            }
            
            if (myClient != null)
            {
              myClient.write("u " + myPlayer.name + " " + myPlayer.team + " " + myPlayer.animationName + " "
              + myPlayer.x + " " + myPlayer.y + "!");
            }
            
            // ------------------------------------ //
            
            if (isMainPlayer)
            {
              if (myClient != null) myClient.write("t " + second() % 10 + "!");
              else timer = second() % 10;
              
              for (int i1 = 0, c1 = players.size(); i1 < c1; i1++)
              {
                if (players.get(i1).team.equals("2"))
                {
                  wwCount++;
                }
                
                if (players.get(i1).isBot)
                {
                  for (int i2 = 0, c2 = players.size(); i2 < c2; i2++)
                  {
                    // AI
                    if (!players.get(i1).team.equals(players.get(i2).team)) 
                    {
                      if (abs((players.get(i1).x - players.get(i2).x) + abs(players.get(i1).y - players.get(i2).y))
                      < players.get(i1).margin2FindTarget_bot)
                      {
                        players.get(i1).margin2FindTarget_bot = abs(players.get(i1).x - players.get(i2).x)
                        + abs(players.get(i1).y - players.get(i2).y);
                        //println(players.get(i1).margin2FindTarget);
                        players.get(i1).target_xy_bot[0] = players.get(i2).x;
                        players.get(i1).target_xy_bot[1] = players.get(i2).y;
                      }
                    }
                    
                    
                    
                    if (myPlayer.canSwitch && checkCollision(players.get(i1).box, players.get(i2).box))
                    {
                      if (players.get(i1).team.equals("1") && players.get(i2).team.equals("2"))
                      {
                        players.get(i1).team = "2";
                        players.get(i1).deathCount++;
                      }
                      else if (players.get(i1).team.equals("2") && players.get(i2).team.equals("1"))
                      {
                        players.get(i1).killCount++;
                      }
                    }
                  }
                  
                  players.get(i1).update4Server();
                  // AI search reset
                  players.get(i1).margin2FindTarget_bot = 100000;
                  
                  if (myClient != null)
                  {
                    myClient.write("u " + players.get(i1).name + " " + players.get(i1).team + " "
                    + players.get(i1).animationName + " " + players.get(i1).x + " " + players.get(i1).y + "!");
                  }
                }
              }
              if (wwCount == players.size())
              {
                if (myClient != null) myClient.write("e n d!");
                else sceneNumber = 3;
              }
              else
              {
                wwCount = 0;
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
                          players.get(i2).x = float(serverData[i1][4]);
                          players.get(i2).y = float(serverData[i1][5]);
                        }
                      }
                      //stroke(0,255,0);
                      //rect(players.get(i2).box[0], players.get(i2).box[1], players.get(i2).box[2], players.get(i2).box[3]);
                    }
                  }
                }
                else if (serverData[i1].length > 0 && serverData[i1][0].equals("t"))
                {
                  timer = int(serverData[i1][1]);
                }
                else if (serverData[i1].length > 0 && serverData[i1][0].equals("e"))
                {
                  sceneNumber = 3;
                }
              }
            }
          break;
        }
      break;
      
      // --------------------------------------------------------------------------------
      
      case 3:
        switch (this.state)
        {
          case 0:
          //send Data
            if (second() %2 == 0 && myClient != null)
            {
              myClient.write("s " + myPlayer.name + " " + myPlayer.deathCount + " " + myPlayer.killCount + "!");
              if (isMainPlayer)
              {
                myClient.write("rc " + myPlayer.roundCount + "!");
                for (int i = 0; i < playerAmount; i++)
                {
                  if (players.get(i).isBot)
                  {
                    myClient.write("s " +  players.get(i).name + " " + players.get(i).deathCount + " " + players.get(i).killCount + "!");
                  }
                }
              }
            }
            if (isMainPlayer)
            {
              stroke(255);
              fill(32);// les boutons "launch" et "map"
              rect(this.button_AABB_2[0], this.button_AABB_2[1], this.button_AABB_2[2], this.button_AABB_2[3], 7);
              fill(255);
              text(this.button_text_1, this.button_AABB_2[0] + this.button_AABB_2[2] * 0.5, this.button_AABB_2[1] + 3);
              
              if (isButtonClicked(this.button_AABB_2)) // button "play again"
              {
                if (myClient != null) myClient.write("play again!");
                else
               {
                 resetGame();
                 players.add(new Player("", false, "1"));
                 playerAmount++;
               }
              }
            }
            fill(0); // draw the array
            for (int i = 0, c = playerAmount + 1; i < c; i++)
            {
              int x = this.button_AABB_1[0];
              int y = this.button_AABB_1[1] + i * (this.button_AABB_1[3]);
              rect( x, y, this.button_AABB_1[2], this.button_AABB_1[3], 7);
              rect( x + this.button_AABB_1[2], y, this.button_AABB_1[2], this.button_AABB_1[3], 7);
              rect( x + this.button_AABB_1[2] * 2, y, this.button_AABB_1[2], this.button_AABB_1[3], 7);
            }
            // draw the text
            for (int i = 0, c = playerAmount; i < c; i++)
            {
              int x = this.button_AABB_1[0] + int(this.button_AABB_1[2] * 0.5);
              int y = 3 + this.button_AABB_1[1] + (i + 1) * int(this.button_AABB_1[3] );//* 0.5);
              
              fill(255, 0, 0);
              text("Game Over in " + myPlayer.roundCount + " round",
              this.button_AABB_1[0] + this.button_AABB_1[2] * 1.5, this.button_AABB_1[1] - this.button_AABB_1[3]);
              fill(255);
              text("Player", x, this.button_AABB_1[1] + 3);
              text("Kills", x + this.button_AABB_1[2], this.button_AABB_1[1] + 3);
              text("Deaths", x + this.button_AABB_1[2] * 2, this.button_AABB_1[1] + 3);
              fill(0, 255, 0); 
              text(players.get(i).name, x, y); // + this.button_AABB_1[3]
              text(players.get(i).killCount, x + this.button_AABB_1[2],  y);
              text(players.get(i).deathCount, x + this.button_AABB_1[2] * 2,  y);
            }
            // receive Data
            if (serverData != null && serverData.length > 0)
            {
              for (int i1 = 0, c1 = serverData.length; i1 < c1; i1++)
              {
                if (serverData[i1].length > 1 && serverData[i1][0].equals("s"))
                {
                  for (int i2 = 0, c2 = players.size(); i2 < c2; i2 ++)
                  {
                    if (serverData[i1][1].equals(players.get(i2).name) && players.get(i2).name != myPlayer.name)
                    {
                      players.get(i2).deathCount = int(serverData[i1][2]);
                      players.get(i2).killCount = int(serverData[i1][3]);
                    }
                  }
                }
                else if (serverData[i1].length > 1 && serverData[i1][0].equals("rc"))
                {
                  if (!isMainPlayer)
                  {
                    myPlayer.roundCount = int(serverData[i1][1]);
                  }
                }
                else if (serverData[i1].length > 1 && serverData[i1][0].equals("play"))
                {
                  resetGame();
                }
              }
            }
          break;
        }
      break;
    }
  }
}

