
local lg = love.graphics
local ls = love.system

Menu = {}

function Menu:load()

  self.canvas = lg.newCanvas(Game.WIDTH, Game.HEIGHT)

  self.lerpTimer = 0

  self.showSettings = false

  self.play = Button:new({
    color = Game.colorPal1:getColor("blue"),
    colorHover = Game.colorPal2:getColor("blue"),
    textColor = Game.colorPal1:getColor("white"),
    x = -Game.WIDTH,
    y = Game.HEIGHT * 0.5,-- Game.HEIGHT * 0.375
    width = Game.WIDTH * 0.5,
    height = Game.HEIGHT * 0.1,
    text = "",
    image = Loader.gfx["play"],
    paddingX = 0.4,
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      self:reset()

      Pointer:reset()

      LevelLoader:initParse(LevelSelect.levels[Save.saveData.currentLevelIndex].file)

      World.currentLevel = LevelSelect.levels[Save.saveData.currentLevelIndex]

      Game.state = "game"
    end
  })

  self.levels = Button:new({
    color = Game.colorPal1:getColor("orange"),
    colorHover = Game.colorPal2:getColor("orange"),
    textColor = Game.colorPal1:getColor("white"),
    x = Game.WIDTH * 0.325 - Game.WIDTH * 0.15 * 0.5,
    y = Game.HEIGHT * 1.25, --Game.HEIGHT * 0.625
    width = Game.WIDTH * 0.15,
    height = Game.WIDTH * 0.15,
    paddingX = -0.025,
    paddingY = -0.025,
    text = "",
    image = Loader.gfx["levels"],
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      self:reset()
      local page = LevelSelect.levels[Save.saveData.currentLevelIndex].page
      LevelSelect.pageScroller.selectedLockIndex = page--World.currentLevel.page
      LevelSelect.pages[page].scroll.content:setYPosition(LevelSelect.levels[Save.saveData.currentLevelIndex])
      Game.state = "level_select"
    end
  })

  self.settings = Button:new({
    color = Game.colorPal1:getColor("red"),
    colorHover = Game.colorPal2:getColor("red"),
    textColor = Game.colorPal1:getColor("white"),
    x = Game.WIDTH * 0.5 - Game.WIDTH * 0.15 * 0.5,
    y = Game.HEIGHT * 1.25, --Game.HEIGHT * 0.625
    width = Game.WIDTH * 0.15,
    height = Game.WIDTH * 0.15,
    paddingX = -0.25,
    paddingY = -0.25,
    text = "",
    image = Loader.gfx["gear"],
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      self.showSettings = not self.showSettings
    end
  })

  self.leaderboard = Button:new({
    color = Game.colorPal1:getColor("green"),
    colorHover = Game.colorPal2:getColor("green"),
    textColor = Game.colorPal1:getColor("white"),
    x = Game.WIDTH * 0.675 - Game.WIDTH * 0.15 * 0.5,
    y = Game.HEIGHT * 1.25, -- Game.HEIGHT * 0.75
    width = Game.WIDTH * 0.15,
    height = Game.WIDTH * 0.15,
    paddingX = -0.175,
    paddingY = -0.175,
    text = "",
    image = Loader.gfx["gamecenter"],
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      ls.showLeaderboard(LEADERBOARD_ID)
    end
  })

  self.sounds = Button:new({
    color = Game.colorPal1:getColor("red"),
    colorHover = Game.colorPal2:getColor("red"),
    textColor = Game.colorPal1:getColor("white"),
    x = Game.WIDTH * 0.5 - Game.WIDTH * 0.15 * 0.75 * 0.5,
    y = Game.HEIGHT * 1.25, --Game.HEIGHT * 0.625
    width = Game.WIDTH * 0.15 * 0.75,
    height = Game.WIDTH * 0.15 * 0.75,
    paddingX = -0.05,
    paddingY = 0.1,
    text = "",
    image = Loader.gfx["soundOn"],
    func = function()

      Save.saveData.sounds = not Save.saveData.sounds

      Slib:save(Save.saveData)

      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
        Loader.sfx["BitzMusic"]:setVolume(1)
      else
        Loader.sfx["BitzMusic"]:setVolume(0)
      end
    end
  })

  self.hapticFeedback = Button:new({
    color = Game.colorPal1:getColor("red"),
    colorHover = Game.colorPal2:getColor("red"),
    textColor = Game.colorPal1:getColor("white"),
    x = Game.WIDTH * 0.5 - Game.WIDTH * 0.15 * 0.75 * 0.5,
    y = Game.HEIGHT * 1.25, --Game.HEIGHT * 0.625
    width = Game.WIDTH * 0.15 * 0.75,
    height = Game.WIDTH * 0.15 * 0.75,
    paddingX = 0.2,
    paddingY = -0.05,
    text = "",
    image = Loader.gfx["hapticOn"],
    func = function()
      Save.saveData.hapticFeedback = not Save.saveData.hapticFeedback

      Slib:save(Save.saveData)

      if(Save.saveData.hapticFeedback) then
        ls.hapticFeedback(2)
      end

      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
    end
  })

  self.testFont = lg.newFont("res/fonts/BloggerSans.otf", Game:scaleWidth(35))
  self.versionFont = lg.newFont("res/fonts/BloggerSans.otf", Game:scaleWidth(18))

  lg.setBackgroundColor(Game.colorPal2:getColor("black"))

  Title:load()
end

function Menu:update(dt)
  Title:update(dt)

  self.play:update(dt)
  self.settings:update(dt)
  self.leaderboard:update(dt)
  self.levels:update(dt)

  if(self.showSettings) then
    self.sounds:update(dt)
    self.hapticFeedback:update(dt)
  end

  self:animate(dt)
end

function Menu:draw()

  lg.setFont(self.testFont)
  self.play:draw()
  if(timer2 >= 0.9) then

    if(Save.saveData.sounds) then
      self.sounds.image = Loader.gfx["soundOn"]
    else
      self.sounds.image = Loader.gfx["soundOff"]
    end
    self.sounds:draw()

    if(Save.saveData.hapticFeedback) then
      self.hapticFeedback.image = Loader.gfx["hapticOn"]
    else
      self.hapticFeedback.image = Loader.gfx["hapticOff"]
    end

    self.hapticFeedback:draw()
  end
  self.settings:draw()
  self.leaderboard:draw()
  self.levels:draw()

  lg.setColor(Game.colorPal1:getColor("white")[1], Game.colorPal1:getColor("white")[2], Game.colorPal1:getColor("white")[3], Title.alpha)
  local versionX = Game.WIDTH - self.versionFont:getWidth("v" .. Game.version) * 1.5
  local versionY = Game.HEIGHT - self.versionFont:getHeight("v" .. Game.version) * 1.75

  lg.setFont(self.versionFont)
  lg.print("v" .. Game.version, versionX, versionY)

  Title:draw()

end

function Menu:touchReleased(id)
  self.play:touchReleased(id)
  self.settings:touchReleased(id)
  self.leaderboard:touchReleased(id)
  self.levels:touchReleased(id)

  if(self.showSettings) then
    self.sounds:touchReleased(id)
    self.hapticFeedback:touchReleased(id)
  end
end

function outBounce(t, b, c, d)
  t = t / d

  if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end

  if t < 2 / 2.75 then
    t = t - (1.5 / 2.75)

    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)

    return c * (7.5625 * t * t + 0.9375) + b
  end

  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
end
timer1 = 0
timer2 = 0
timer3 = 0
timer4 = 0

function Menu:animate(dt)
  self.lerpTimer = Lume.lerp(self.lerpTimer, 1, dt * 0.25)--self.lerpTimer + dt * .25
  Title.alpha = Lume.lerp(Title.alpha, 1, self.lerpTimer * self.lerpTimer)

  self.play.x = Lume.smooth(self.play.x, Game.WIDTH * 0.5 - Game.WIDTH * 0.5 * 0.5, dt * 16)
  timer1 = Lume.lerp(timer1, 1, dt * 3)
  timer2 = Lume.lerp(timer2, 1, dt * 2.75)
  timer3 = Lume.lerp(timer3, 1, dt * 2.5)

  self.levels.y = outBounce(timer1, Game.HEIGHT * 1.25, Game.HEIGHT * 0.625 - Game.HEIGHT * 1.25, 1)--Lume.smooth(self.levels.y, Game.HEIGHT * 0.625, dt * 11)
  self.settings.y = outBounce(timer2, Game.HEIGHT * 1.25, Game.HEIGHT * 0.625 - Game.HEIGHT * 1.25, 1)
  self.leaderboard.y = outBounce(timer3, Game.HEIGHT * 1.25, Game.HEIGHT * 0.625 - Game.HEIGHT * 1.25, 1)

  if(self.showSettings) then
    timer4 = Lume.lerp(timer4, 1, dt * 4)
    self.sounds.y = outBounce(timer4, self.settings.y, self.settings.y + self.settings.height * 1.25 - self.settings.y, 1)--Lume.smooth(self.sounds.y, self.settings.y + self.settings.height * 1.25, dt * 8)
    self.hapticFeedback.y = self.sounds.y + self.settings.height

    self.sounds.enabled = true
    self.hapticFeedback.enabled = true
  else
    timer4 = 0
    self.sounds.y = Lume.smooth(self.sounds.y, self.settings.y + self.settings.height * 0.15, dt * 16)
    self.hapticFeedback.y = self.sounds.y
    self.sounds.enabled = false
    self.hapticFeedback.enabled = false
  end
end

function Menu:reset()
  self.showSettings = false
  self.lerpTimer = 0
  self.play.x = -Game.WIDTH
  self.settings.y = Game.HEIGHT * 1.25
  self.leaderboard.y = Game.HEIGHT * 1.25
  self.levels.y = Game.HEIGHT * 1.25
  timer1 = 0
  timer2 = 0
  timer3 = 0
  timer4 = 0

  Title:reset()
end
