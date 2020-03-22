
local lg = love.graphics
local ls = love.system
local lw = love.window

Game = {}

Game.WIDTH = lg:getWidth()
Game.HEIGHT = lg:getHeight()
Game.O_WIDTH =  375
Game.O_HEIGHT = 667

Game.version = "1.0.1"

Game.state = "menu"

Game.checkScore = false

Game.connected = false
Game.connectionTimer = 0

Game.DEBUG = false

Game.blockCount = 0

Game.askedReview = false
Game.reviewTimer = 0

function Game:load()

  AdHandler:load()

  love.audio.setMixWithSystem(true)

  self.showingBanner = false
  self.tapCounts = 0

  self.colorPal1 = ColorPalette:new({
    ["black"] = {64, 64, 122},
    ["purple"] = {112, 111, 211},
    ["white"] = {247, 241, 227},
    ["blue"] = {52, 172, 224},
    ["green"] = {51, 217, 178},
    ["red"] = {255, 82, 82},
    ["orange"] = {255, 121, 63},
    ["gray"] = {209, 204, 192},
    ["yellow"] = {255, 177, 66},
    ["yellow_light"] = {255, 218, 121},
    ["teal"] = {109, 216, 216}
  }, 255)

  self.colorPal2 = ColorPalette:new({
    ["black"] = {44, 44, 84},
    ["purple"] = {71, 71, 135},
    ["white"] = {170, 166, 157},
    ["blue"] = {34, 112, 147},
    ["green"] = {33, 140, 116},
    ["red"] = {179, 57, 57},
    ["orange"] = {205, 97, 51},
    ["gray"] = {132, 129, 122},
    ["yellow"] = {204, 142, 53},
    ["yellow_light"] = {204, 174, 98},
    ["teal"] = {0, 186, 181}
  }, 255)

  self.colorPal3 = ColorPalette:new({
    ["green"] = {33 * 0.75, 140 * 0.75, 116 * 0.75},
    ["blue"] = {0 * 1.25, 78 * 1.25, 146 * 1.25},
    ["blue_half"] = {0, 42 * 1.35, 93 * 1.35},
    ["blue_half_2"] = {0, 32, 82},
    ["dark_blue"] = {0, 4 * 1.25, 40 * 1.25}
  }, 255)

  Save:load()

  self:checkUpdate()

  self.background = lg.newCanvas(self.WIDTH, self.HEIGHT)

  lg.setCanvas(self.background)
  lg.clear()
  lg.rectangle("fill", 0, 0, self.WIDTH, self.HEIGHT)
  lg.setCanvas()

  Gradient:send("r", self.colorPal3:getColor("dark_blue")[1])
  Gradient:send("g", self.colorPal3:getColor("dark_blue")[2])
  Gradient:send("b", self.colorPal3:getColor("dark_blue")[3])

  Gradient:send("r1", self.colorPal3:getColor("blue")[1])
  Gradient:send("g1", self.colorPal3:getColor("blue")[2])
  Gradient:send("b1", self.colorPal3:getColor("blue")[3])

  self.consoleFont = lg.newFont(16)

  Pointer:load()
  Obelus:load()
  DottedSquare:load()

  Level:load()
  LevelSelect:load()
  Menu:load()
  World:load()
  Win:load()

  if(not Save.saveData.sounds) then
    Loader.sfx["BitzMusic"]:setVolume(0)
  end
  Loader.sfx["BitzMusic"]:play() -- Play jingle after everything is loaded
end

local connected

function Game:update(dt)

  self:checkConnection(dt)

  AdHandler:update(dt)

  self.blockCount = 0

  if(IOS) then
    connected = ls.isConnected()
  end

  if(not self.askedReview) then
    self.reviewTimer = self.reviewTimer + dt

    if(self.reviewTimer >= 600 and (self.state == "menu" or self.state == "level_select")) then
      ls.requestReview()
      self.askedReview = true
    end
  end

  for i = 1, LevelSelect.numLevels do
    self.blockCount = self.blockCount + LevelSelect.levels[i].rating
  end

  if(self.reviewTimer >= 10 and not self.checkScore and IOS) then
    local a = ls.getHighScore(LEADERBOARD_ID)
    if(a < Save.saveData.highscore) then
      if(ls.isConnected()) then
        ls.submitScore(LEADERBOARD_ID, Save.saveData.highscore)
      end

    end

    self.checkScore = true
  end

  if(self.blockCount > Save.saveData.highscore and IOS) then
    Save.saveData.highscore = self.blockCount
    Save:save()

    if(ls.isConnected()) then
      ls.submitScore(LEADERBOARD_ID, Save.saveData.highscore)
    end

  end

  if(self.DEBUG) then
  --  Console:print(love.timer.getFPS())
    Console:intervalPrint(1, 1, dt, love.timer.getFPS())
    Console:update(dt)
  end

  if(self.state == "menu") then
    Menu:update(dt)
  elseif(self.state == "level_select") then
    LevelSelect:update(dt)
  elseif(self.state == "game") then
    World:update(dt)

    for i = 1, #Confetti do
      Confetti[i]:update(dt)
    end

    for i = #Confetti, 1, - 1  do
      if(Confetti[i].remove) then
        table.remove(Confetti, i)
      end
    end
  end

  for i = #Dust, 1, -1 do if(Dust[i].remove) then table.remove(Dust, i) end end
  if(#Toast > 0) then Toast[1]:update(dt) end
  for i = #Toast, 1, -1 do if(Toast[i].remove) then table.remove(Toast, i) end end

end

function Game:draw()

  lg.setShader(Gradient)
  lg.draw(self.background)
  lg.setShader()

  if(self.state == "menu") then
    Menu:draw()
    if(IOS and self.showingBanner) then
      love.ads.hideBanner()
      self.showingBanner = false
    end
  elseif(self.state == "level_select") then
    LevelSelect:draw()
    if(IOS and self.showingBanner) then
      love.ads.hideBanner()
      self.showingBanner = false
    end
  elseif(self.state == "game") then
    World:draw()
    for i = 1, #Confetti do
      Confetti[i]:draw()
    end

    if(IOS and not Save.saveData.unlockedAds and not self.showingBanner) then
      love.ads.showBanner()
      self.showingBanner = true
    end

    if(IOS and not Save.saveData.unlockedAds and not self.connected) then
      lg.setColor(Game.colorPal1:getColor("white"))
      lg.rectangle("fill", 0, Game.HEIGHT - 50 - bottom, Game.WIDTH, 50)
    end

  else
      Title:draw()
  end

  if(#Toast > 0) then
    Toast[1]:draw()
  end

  if(self.DEBUG) then
    lg.setFont(self.consoleFont)
    Console:draw()
  end

end

function Game:touchReleased(id, x, y)
  if(self.state == "menu") then
    Menu:touchReleased(id)

    if(x > self.WIDTH * 0.85 and y > self.HEIGHT * 0.85) then
      self.tapCounts = self.tapCounts + 1
      if(self.tapCounts >= 30) then
        if(Save.saveData.sounds) then
          local a = Loader.sfx["TouchForward"]:play()
        end
        Save.saveData.unlockedAds = not Save.saveData.unlockedAds

        if(not Save.saveData.unlockedAds) then
          Toast[#Toast + 1] = Toast:new({
              messageType = "GOOD",
              text = "Ads On"
          })
        else
          Toast[#Toast + 1] = Toast:new({
              messageType = "ERROR",
              text = "Ads Off"
          })
        end
        Save:save()
        self.tapCounts = 0
      end
    end

  elseif(self.state == "level_select") then
    self.tapCounts = 0
    LevelSelect:touchReleased(id)
  elseif(self.state == "game") then
    self.tapCounts = 0
    World:touchReleased(id, x, y)
  else
  end
end

function Game:touchMoved(id, x, y, dx, dy)
  if(self.state == "level_select") then
    LevelSelect:touchMoved(id, x, y, dx, dy)
  else
  end
end

function Game:scaleWidth(num)
  return self.WIDTH * (num / self.O_WIDTH)
end

function Game:scaleHeight(num)
  return self.HEIGHT * (num / self.O_HEIGHT)
end

local factor = 0

function Game:checkConnection(dt)

  factor = (self.connected) and (1) or 4

  self.connectionTimer = self.connectionTimer + dt * factor

  if(self.connectionTimer >= 30 and IOS) then

    local connected = ls.isConnected()

    if(not self.connected and connected) then
      love.ads.createBanner(AdHandler.AD_BANNER_ID, "bottom")
      self.showingBanner = false
      self.connected = true
    end

    if(self.connected and not connected) then
      self.connected = false
    end

    self.connectionTimer = 0

  end
end

function Game:checkUpdate()
  if(IOS) then
    love.ads.createBanner(AdHandler.AD_BANNER_ID, "bottom")
    local connected  = ls.isConnected()

    -- Check for update
    if(connected) then
      self.connected = true
      local bundleVersion = ls.getVersionNumber()

      if(bundleVersion ~= self.version) then

        local buttons = {"Dismiss", "Update!", escapeButton = 1}

        local updateMessage = lw.showMessageBox("Update!", "An update is available for bitz!", buttons)

        if(updateMessage == 2) then
          ls.openURL("https://itunes.apple.com/app/id1447543082")
        end

      end

    end
  end

end

function Game:requestReview()
  ls.requestReview()
end
