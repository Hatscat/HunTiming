class Player
{
  int axeX, axeY, playerPixelPosition, posX2CenterTheText, 
  movementState_bot, timer_bot, moveRound_bot, roundCount, deathCount, killCount;
  int[] box; 
  String name, animationName, team, previousTeam;
  float x, y, speed, repulsionStrength, randomPx, margin2FindTarget_bot;
  float[] target_xy_bot;
  boolean isBot, canSwitch;
  boolean[] bannedMovement_bot;
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
    this.randomPx = this.deathCount = this.killCount 
    = this.movementState_bot = this.timer_bot = this.moveRound_bot = 0;
    this.roundCount = 1;
    this.margin2FindTarget_bot = 100000;
    
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
    this.box = new int[] { int(this.x), int(this.y), this.w, this.h };
    this.bannedMovement_bot = new boolean[] {false, false};
    this.target_xy_bot = new float[] {0, 0};
    this.playerPixelPosition = 10000;
    this.posX2CenterTheText = int(this.w * 0.5);
    this.canSwitch = true;
    //this.canCollide = true;
  }
  
///----------------------------------------------------------------------
  
  void update4Server()
  {
     //---Gere l'udate des deplacements de myPlayer  
    if (!this.isBot) // si c'est un joueur
    {
      this.axeX = this.axeY = 0;
      if (movingLeft)       this.axeX = -1;
      if (movingRight)      this.axeX = 1;
      if (movingUp)         this.axeY = -1;
      if (movingDown)       this.axeY = 1;
      
      if (this.team != this.previousTeam) // détection d'un changement de team, pour jouer un son correspondant, à faire uniqement côté client!
      {
        this.previousTeam = this.team;
        //this.canCollide = false;
        sound_switch.trigger();
      }
    }
    else // si c'est un bot
    {
      
      if (this.team.equals("1"))
      {
        if (this.x < target_xy_bot[0])         this.axeX = -1;
        else if (this.x > target_xy_bot[0])    this.axeX = 1;
        if (this.y < target_xy_bot[0])         this.axeY = -1;
        else if (this.y > target_xy_bot[0])    this.axeY = 1;
      }
      else
      {
        if (this.x < target_xy_bot[0])         this.axeX = 1;
        else if (this.x > target_xy_bot[0])    this.axeX = -1;
        if (this.y < target_xy_bot[0])         this.axeY = 1;
        else if (this.y > target_xy_bot[0])    this.axeY = -1;
      }
      /*
      if (this.timer_bot >= 32)
      {
        this.timer_bot = 0;
        this.moveRound_bot++;
        switch (this.movementState_bot)
        {
          case 0:
            this.axeX = 1;
            this.axeY = 0;
          break;
          case 1:
            this.axeX = -1;
            this.axeY = 0;
          break;
          case 2:
            this.axeX = 0;
            this.axeY = 1;
          break;
          case 3:
            this.axeX = 0;
            this.axeY = -1;
          break;
        }
      }
      else
      {
        this.timer_bot++;
        this.moveRound_bot = 0;
      }
      if (this.team.equals("1"))
      {
        if (target_xy_bot[0] > target_xy_bot[1])
        {
          if (this.x < target_xy_bot[0])
          {
            if (!this.bannedMovement_bot[0]) this.axeX = -1;
            else this.axeX = 1;
          }
          else if (this.x > target_xy_bot[0])
          {
            if (!this.bannedMovement_bot[0]) this.axeX = 1;
            else this.axeX = -1;
          }
        }
        else
        {
          if (this.y < target_xy_bot[1])
          {
            if (!this.bannedMovement_bot[1]) this.axeY = -1;
            else this.axeY = 1;
          }
          else if (this.y > target_xy_bot[1])
          {
            if (!this.bannedMovement_bot[1]) this.axeY = 1;
            else this.axeY = -1;
          }
        }
        
       
        
      }
      else
      {
        if (this.x < target_xy_bot[0])
        {
          if (!this.bannedMovement_bot[0]) this.axeX = 1;
          else this.axeX = -1;
        }
        else if (this.x > target_xy_bot[0])
        {
          if (!this.bannedMovement_bot[0]) this.axeX = -1;
          else this.axeX = 1;
        }
        if (this.y < target_xy_bot[1])
        {
          if (!this.bannedMovement_bot[1]) this.axeY = 1;
          else this.axeY = -1;
        }
        else if (this.y > target_xy_bot[1])
        {
          if (!this.bannedMovement_bot[1]) this.axeY = -1;
          else this.axeY = 1;
        }
      }*/
    }
    
    if (timer == 0)
    {
      if (this.canSwitch)
      {
        this.canSwitch = false;
        this.roundCount++;
        if (this.team.equals("1")) this.team = "2";
        else this.team = "1";
      }
    }
    else this.canSwitch = true;
    
    
    if (this.axeX != 0 && this.axeY != 0)
    {
      this.x += this.axeX * (this.speed * 0.7);
      this.y += this.axeY * (this.speed * 0.7);
      this.repulsionStrength = this.speed * 2;
    }
    else
    {
      this.x += this.axeX * this.speed;
      this.y += this.axeY * this.speed;
      this.repulsionStrength = this.speed;
    }
    
    this.playerPixelPosition = (int(this.y) + int(this.h * 0.5)) * width + int(this.x) + int(this.w * 0.5) + 1; // pour les collisions
    
    if (this.y <= 5) this.y += this.repulsionStrength;
    else if (this.y + this.h + 5 >= height) this.y -= this.speed * 3;
    else if (this.x <= 5) this.x += this.repulsionStrength;
    else if (this.x + this.w + 5 >= width) this.x -= this.repulsionStrength;
    
    if (!this.isBot)
    {
      try
      {
        if (px[this.playerPixelPosition - int(this.h * 0.5 * width)] == map_wall_value) //
        {
          this.y += this.repulsionStrength;
        }
        else if (px[this.playerPixelPosition + int(this.h * 0.5 * width)] == map_wall_value) //
        {
          this.y -= this.repulsionStrength;
        }
        else if (px[this.playerPixelPosition - int(this.w * 0.5)] == map_wall_value) //
        {
          this.x += this.repulsionStrength;
        }
        else if (px[this.playerPixelPosition + int(this.w * 0.5)] == map_wall_value) //
        {
          this.x -= this.repulsionStrength;
        }
        else if (px[this.playerPixelPosition] == map_tower_value) //
        {
          this.randomPx = random(tower_px.size());
          this.x = tower_px.get(int(randomPx)) % width;
          this.y = floor(tower_px.get(int(randomPx)) / width);
        }
      }
      catch (Exception error)
      {
        println("\n/!\\ position or collision error !");
        error.printStackTrace();
      }
    }
    else // si c'est un bot
    {
      try
      {
        if (px[this.playerPixelPosition - int(this.h * 0.5 * width)] == map_wall_value) //
        {
          this.y += this.repulsionStrength;
          //this.bannedMovement_bot[1] = !this.bannedMovement_bot[1];
        }
        else if (px[this.playerPixelPosition + int(this.h * 0.5 * width)] == map_wall_value) //
        {
          this.y -= this.repulsionStrength;
          //this.bannedMovement_bot[1] = !this.bannedMovement_bot[1];
        }
        else if (px[this.playerPixelPosition - int(this.w * 0.5)] == map_wall_value) //
        {
          this.x += this.repulsionStrength;
          //this.bannedMovement_bot[0] = !this.bannedMovement_bot[0];
        }
        else if (px[this.playerPixelPosition + int(this.w * 0.5)] == map_wall_value) //
        {
          this.x -= this.repulsionStrength;
          //this.bannedMovement_bot[0] = !this.bannedMovement_bot[0];
        }
        else if (px[this.playerPixelPosition] == map_tower_value) //
        {
          this.randomPx = random(tower_px.size());
          this.x = tower_px.get(int(randomPx)) % width;
          this.y = floor(tower_px.get(int(randomPx)) / width);
        }
      }
      catch (Exception error)
      {
        println("\n/!\\ position or collision error !");
        error.printStackTrace();
      }
    }
    
    //---Gere l'update des animations de myPlayer
    if (this.axeY == -1)        this.animationName = "u";
    else if (this.axeY == 1)    this.animationName = "d";
    else if (this.axeX == -1)   this.animationName = "l";
    else if (this.axeX == 1)    this.animationName = "r";
    else                        this.animationName = "i";
  }
  
///----------------------------------------------------------------------  
  
  void clientUpdate()
  {
    //---Gere le rendu des animations en fonction de l'équipe!!
    this.box[0] = int(this.x);
    this.box[1] = int(this.y);
    
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

