
local lg = love.graphics
local ls = love.system

local OFFSET = Game.HEIGHT * 0.01
local ROUNDNESS = 0

PauseWindow = {}

function PauseWindow:load()
  self.scaleTimer = 0
  self.scale = 0
  self.x = Game.WIDTH * 0.5 * 0.25
  self.width = Game.WIDTH * 0.75
  self.height = Game.HEIGHT * 0.5
  self.y = Game.HEIGHT * 0.5 - self.height * 0.5

  ROUNDNESS = Game:scaleWidth(20)

  self.continue = Button:new({
    x = self.x + self.width * 0.5 - self.width * 0.65 * 0.5,
    y = self.y + self.height * 0.35,
    width = self.width * 0.65,
    height = self.width * 0.2,
    color = Game.colorPal1:getColor("green"),
    colorHover = Game.colorPal2:getColor("green"),
    imageColor = Game.colorPal1:getColor("white"),
    text = "",
    image = Loader.gfx["play"],
    paddingX = 0.5,
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      World.pause = false
      self:reset()
    end
  })

  self.levels = Button:new({
    x = self.x + self.width * 0.275,
    color = Game.colorPal1:getColor("orange"),
    colorHover = Game.colorPal2:getColor("orange"),
    imageColor = Game.colorPal1:getColor("white"),
    text = "",
    width = self.continue.width * 0.3,
    height = self.continue.width * 0.3,
    image = Loader.gfx["levels"],
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      Game.state = "level_select"

      LevelSelect.pageScroller.selectedLockIndex = World.currentLevel.page
      LevelSelect.pages[World.currentLevel.page].scroll.content:setYPosition(World.currentLevel)

      self:reset()
    end
  })

  self.home = Button:new({
    x = self.x + self.width * 0.525,
    color = Game.colorPal1:getColor("red"),
    colorHover = Game.colorPal2:getColor("red"),
    imageColor = Game.colorPal1:getColor("white"),
    text = "",
    width = self.continue.width * 0.3,
    height = self.continue.width * 0.3,
    image = Loader.gfx["home"],
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      Game.state = "menu"
      World:reset()
      self:reset()
    end
  })

  self.sounds = Button:new({
    x = self.x + self.width * 0.275,
    color = Game.colorPal1:getColor("purple"),
    colorHover = Game.colorPal2:getColor("purple"),
    imageColor = Game.colorPal1:getColor("white"),
    text = "",
    width = self.continue.width * 0.3,
    height = self.continue.width * 0.3,
    image = Loader.gfx["soundOn"],
    paddingX = 0.1,
    paddingY = 0.15,
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
    x = self.x + self.width * 0.525,
    color = Game.colorPal1:getColor("blue"),
    colorHover = Game.colorPal2:getColor("blue"),
    imageColor = Game.colorPal1:getColor("white"),
    text = "",
    width = self.continue.width * 0.3,
    height = self.continue.width * 0.3,
    image = Loader.gfx["hapticOn"],
    paddingX = 0.2,
    paddingY = -0.05,
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

end

function PauseWindow:update(dt)
  self:animate(dt)

  self.continue:update(dt)
  self.levels:update(dt)
  self.home:update(dt)
  self.sounds:update(dt)
  self.hapticFeedback:update(dt)
end

function PauseWindow:draw()

  lg.push()

  lg.translate(self.x + self.width * 0.5, self.y + self.height * 0.5)

  lg.scale(self.scale)

  lg.translate(-self.x - self.width * 0.5, - self.y - self.height * 0.5)

  lg.setColor(Game.colorPal2:getColor("white"))
  lg.rectangle("fill", self.x, self.y + OFFSET, self.width, self.height, ROUNDNESS, ROUNDNESS)
  lg.setColor(Game.colorPal1:getColor("white"))
  lg.rectangle("fill", self.x, self.y, self.width, self.height, ROUNDNESS, ROUNDNESS)

  ----------- RENDER BANNER -----------
  lg.setColor(Game.colorPal2:getColor("green"))
  lg.rectangle("fill", self.x - self.width * 0.1, self.y + self.height * 0.075, self.width * 0.1, self.height * 0.15)
  lg.rectangle("fill", self.x + self.width, self.y + self.height * 0.075, self.width * 0.1, self.height * 0.15)

  lg.setColor(Game.colorPal3:getColor("green"))
  lg.polygon("fill",
   self.x - self.width * 0.05, self.y + self.height * 0.05 + self.height * 0.15,
   self.x, self.y + self.height * 0.05 + self.height * 0.15,
   self.x, self.y + self.height * 0.075 + self.height * 0.15)
  lg.polygon("fill",
    self.x + self.width + self.width * 0.05, self.y + self.height * 0.05 + self.height * 0.15,
    self.x + self.width, self.y + self.height * 0.05 + self.height * 0.15,
    self.x + self.width, self.y + self.height * 0.075 + self.height * 0.15)

  lg.setColor(Game.colorPal1:getColor("green"))
  lg.rectangle("fill", self.x - self.width * 0.05, self.y + self.height * 0.05, self.width + self.width * 0.1, self.height * 0.15)
  -------------------------------------

  lg.setFont(Menu.testFont)
  lg.setColor(Game.colorPal1:getColor("white")[1], Game.colorPal1:getColor("white")[2], Game.colorPal1:getColor("white")[3])
  local testWidth = Menu.testFont:getWidth("Paused") * 0.5
  lg.print("Paused", self.x + self.width * 0.5 - testWidth, self.y + self.height * 0.1)

  self.continue:draw()

  self.levels:draw()
  self.home:draw()

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

  lg.pop()
end

function PauseWindow:animate(dt)

  self.scaleTimer = Lume.lerp(self.scaleTimer, 1, dt * 2)
  self.scale = Lume.outElastic(self.scaleTimer, 0, 1, 1)

  self.continue.y = self.y + self.height * 0.725
  self.levels.y = self.y + self.height * 0.325
  self.home.y = self.levels.y
  self.sounds.y = self.home.y + self.sounds.height * 1.2
  self.hapticFeedback.y = self.sounds.y
end

function PauseWindow:touchReleased(id)
  self.continue:touchReleased(id)
  self.levels:touchReleased(id)
  self.home:touchReleased(id)
  self.sounds:touchReleased(id)
  self.hapticFeedback:touchReleased(id)
end

function PauseWindow:reset()
  self.scaleTimer = 0
  self.scale = 0
end
