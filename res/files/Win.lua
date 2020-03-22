
local lg = love.graphics

local OFFSET = Game.HEIGHT * 0.01
local ROUNDNESS = 0

local Box = {}

Box.__index = Box

function Box:new(properties)
  local self = {}

  self.lerpTimer = 0
  self.backgroundAlpha = 0

  self.scaleTimer = 0
  self.scale = 0

  self.x = properties.x
  self.y = properties.y
  self.size = properties.size

  self.shadowScaleX = (self.size / Loader.gfx["boxshadow"]:getWidth()) * 1.6
  self.shadowScaleY = (self.size / Loader.gfx["boxshadow"]:getHeight()) * 1.6
  self.shadowOffsetX = -self.size * 0.3
  self.shadowOffsetY = -self.size * 0.1
  self.shadowIntensity = 0.3

  self.color = properties.color
  self.color2 = properties.color2

  self.playedPop = false

  self.offset = 0
  self.trueOffset = self.size * 0.15

  self.r = properties.r

  return setmetatable(self, Box)
end

function Box:update(dt)

  if(not self.playedPop and Save.saveData.sounds) then
    local a = Loader.sfx["AwardPop"]:play()
    a:setPitch(math.random(90, 110) * 0.01)
    self.playedPop = true
  end

  self.offset = Lume.smooth(self.offset, self.trueOffset, dt * 8)
  self.scaleTimer = Lume.lerp(self.scaleTimer, 1, dt * 4)
  self.scale = Lume.outElastic(self.scaleTimer, 0, 1, 4)
end

function Box:draw()

  lg.push()

  lg.translate(self.x + self.size * 0.5, self.y + self.size * 0.5)
  lg.scale(self.scale)
  lg.translate(-self.x - self.size * 0.5, -self.y - self.size * 0.5)

  lg.setColor(0, 0, 0, self.shadowIntensity)
  lg.draw(Loader.gfx["boxshadow"], self.x + self.shadowOffsetX, self.y + self.shadowOffsetY, 0, self.shadowScaleX, self.shadowScaleY)
  lg.setColor(self.color2)
  lg.rectangle("fill", self.x, self.y, self.size, self.size, self.r, self.r)
  lg.setColor(self.color)
  lg.rectangle("fill", self.x, self.y, self.size, self.size - self.offset, self.r, self.r)

  lg.pop()
end

Win = {}


local SCORE_KEYS = {
  [1] = "Nice!",
  [2] = "Great!",
  [3] = "Perfect!"
}

function Win:load()

  self.confettiTimer = 0
  self.confettiCalls = 0

  self.incrementInter = false

  self.scoreText = SCORE_KEYS[1]
  self.scoreY = 0

  self.scale = 0
  self.scaleTimer = 0

  self.score = 0
  self.x = Game.WIDTH * 0.5 * 0.25
  self.width = Game.WIDTH * 0.75
  self.height = Game.HEIGHT * 0.5
  self.y = Game.HEIGHT * 0.5 - self.height * 0.5

  self.iWidth = self.width / 4

  self.scoreRectSize = (self.width / 3) * 0.6

  self.savedData = false

  ROUNDNESS = Game:scaleWidth(20)

  self.COLOR_KEYS = {
    Game.colorPal1:getColor("blue"),
    Game.colorPal1:getColor("orange"),
    Game.colorPal1:getColor("red")
  }

  self.COLOR_KEYS2 = {
    Game.colorPal2:getColor("blue"),
    Game.colorPal2:getColor("orange"),
    Game.colorPal2:getColor("red")
  }

  self.scoreBoxes = {}
  for i = 1, 3 do
    self.scoreBoxes[i] = Box:new({
      x = 0,
      y = self.y,
      size = self.scoreRectSize,
      color = self.COLOR_KEYS[i],
      color2 = self.COLOR_KEYS2[i],
      r = ROUNDNESS * 0.5
    })
  end

  self.timer = 3

  self.iWidth2 = self.width / 4

  self.next = Button:new({
    x = self.x + self.width * 0.71875 - (self.width * 0.375 * 0.5), -- self.iWidth * 2.75,
    y = self.y,
    color = Game.colorPal1:getColor("green"),
    colorHover = Game.colorPal2:getColor("green"),
    imageColor = Game.colorPal1:getColor("white"),
    text = "",
    width = self.width * 0.375,
    height = self.width * 0.25 * 0.75,
    image = Loader.gfx["next"],
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      self:reset()
      Pointer:reset()
      local file = World.currentLevel.fileIndex + 1

      if(file > #LevelSelect.levels) then
        file = 1
      end

      local theFile = LevelSelect.levels[file]

      LevelLoader:initParse(theFile.file)

      World.currentLevel = theFile
      Save.saveData.currentLevelIndex = theFile.fileIndex

      Save:save()
    end
  })

  self.redo = Button:new({
    x = self.x + self.width * 0.4 - (self.width * 0.1875 * 0.5), -- self.iWidth * 1.75
    y = self.y,
    color = Game.colorPal1:getColor("yellow"),
    colorHover = Game.colorPal2:getColor("yellow"),
    imageColor = Game.colorPal1:getColor("white"),
    text = "",
    width = self.width * 0.1875,
    height = self.width * 0.1875,
    paddingX = -0.2,
    paddingY = -0.2,
    image = Loader.gfx["redo"],
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      Pointer:reset()
      local temp = World.currentLevel

      World:softReset()
      LevelLoader:initParse(World.currentLevel.file)

      World.currentLevel = temp

      self:reset()

    end
  })

  self.back = Button:new({
    x = self.x + self.width * 0.1875 - (self.width * 0.1875 * 0.5), -- self.iWidth * 0.75
    y = self.y,
    color = Game.colorPal1:getColor("orange"),
    colorHover = Game.colorPal2:getColor("orange"),
    imageColor = Game.colorPal1:getColor("white"),
    text = "",
    width = self.width * 0.1875,
    height = self.width * 0.1875,
    image = Loader.gfx["levels"],
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end

      local file = World.currentLevel.fileIndex + 1

      if(file > #LevelSelect.levels) then
        file = 1
      end

      local theFile = LevelSelect.levels[file]

      Save.saveData.currentLevelIndex = theFile.fileIndex

      Save:save()

      Game.state = "level_select"

      LevelSelect.pageScroller.selectedLockIndex = World.currentLevel.page
      LevelSelect.pages[World.currentLevel.page].scroll.content:setYPosition(World.currentLevel)

      self:reset()
    end
  })

  self.playedJingle = false
  self.backgroundAlpha = 0
  self.lerpTimer = 0
end

function Win:update(dt)

  if(not self.incrementInter) then
    AdHandler.interSteps = AdHandler.interSteps + 1
    AdHandler:initInterstitial()
    self.incrementInter = true
  end

  local file = World.currentLevel.fileIndex + 1

  if(file > #LevelSelect.levels) then
    self.next.enabled = false
  else
    self.next.enabled = true
  end

  self:determineScore()

  self:animate(dt)

  self.back:update(dt)
  self.next:update(dt)
  self.redo:update(dt)

  for i = 1, Lume.roundP(self.score - self.timer) do
    self.scoreBoxes[i]:update(dt)
  end

end

local testWidth, fontWidth, fontHeight

function Win:draw()

  lg.setColor(0, 0, 0, self.backgroundAlpha)
  lg.rectangle("fill", 0, 0, Game.WIDTH, Game.HEIGHT)

  lg.push()

  lg.translate(self.x + self.width * 0.5, self.y + self.height * 0.5)
  lg.scale(self.scale)
  lg.translate(-self.x - self.width * 0.5, -self.y - self.height * 0.5)

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
  lg.setColor(Game.colorPal1:getColor("white")[1], Game.colorPal1:getColor("white")[2], Game.colorPal1:getColor("white")[3], 1)

  testWidth = Menu.testFont:getWidth("Level " .. tonumber(World.currentLevel.name)) * 0.5
  fontWidth = Menu.testFont:getWidth(self.scoreText)
  fontHeight = Menu.testFont:getHeight("M")

  lg.setScissor(self.x, self.y + self.height * 0.05, self.width, self.height * 0.15)
  lg.print(self.scoreText, self.x + self.width * 0.5 - fontWidth * 0.5, self.y + self.height * 0.15 - fontHeight * 0.5 - self.scoreY)
  lg.print("Level " .. tonumber(World.currentLevel.name), self.x + self.width * 0.5 - testWidth, self.y + self.height * 0.45 - self.scoreY)
  lg.setScissor()


  lg.setColor(Game.colorPal1:getColor("black")[1], Game.colorPal1:getColor("black")[2], Game.colorPal1:getColor("black")[3], 0.5)
  local testWidth = Menu.testFont:getWidth(World.moves .. "   /   " .. World.minMoves) * 0.5
  lg.print(World.moves .. "   /   " .. World.minMoves, self.x + self.width * 0.5 - testWidth, self.y + self.height * 0.525)

  lg.setColor(1, 1, 1, 1)

  lg.setColor(Game.colorPal2:getColor("gray"))
  for i = 1, 3 do

    lg.rectangle("fill",self.x + (i * self.iWidth) - self.scoreRectSize * 0.5, self.y + self.height * 0.25, self.scoreRectSize, self.scoreRectSize, ROUNDNESS * 0.5, ROUNDNESS * 0.5)

  end

  local xx = self.x
  for i = 1, Lume.roundP(self.score - self.timer) do

    self.scoreBoxes[i].x = self.x + (i * self.iWidth) - self.scoreRectSize * 0.5
    self.scoreBoxes[i].y = self.y + self.height * 0.25
    self.scoreBoxes[i]:draw()
  end

  self.back:draw()
  self.next:draw()
  self.redo:draw()

  lg.pop()
end

function Win:touchReleased(id)
  if(AdHandler.interSteps < 3) then
    self.back:touchReleased(id)
    self.next:touchReleased(id)
    self.redo:touchReleased(id)
  end
end

--timer8 = 0

function Win:animate(dt)

  if(self.timer <= 0.25) then
    self.scoreY = Lume.smooth(self.scoreY, self.y - self.height * 0.15, dt * 8.5)
  end

  self.confettiTimer = self.confettiTimer + dt

  if(self.score >= 3 and self.confettiTimer >= .1 and self.confettiCalls <= 6) then

    self.confettiCalls = self.confettiCalls + 1
    for i = 1, 12 do
      Confetti[#Confetti + 1] = Confetti:new({
        x = -Game.WIDTH * 0.1,
        y = 0,
        velX = math.random(1000, 800),
        angle = math.pi * 0.25
      })
      Confetti[#Confetti + 1] = Confetti:new({
        x = Game.WIDTH,
        y = 0,
        velX = math.random(1000, 800),
        angle = math.pi - math.pi * 0.25
      })
      Confetti[#Confetti + 1] = Confetti:new({
        x = Game.WIDTH * 0.5,
        y = 0,
        velX = math.random(1000, 800),
        angle = math.pi * 0.5
      })
    end

    self.confettiTimer = 0
  end


  self.scaleTimer = Lume.lerp(self.scaleTimer, 1, dt * 2)

  self.scale = Lume.outElastic(self.scaleTimer, 0, 1, 1)

  --timer8 = Lume.lerp(timer8, 1, dt * 4)

  --self.y = outBounce(timer8, -self.height * 1, Game.HEIGHT * 0.5 - self.height * 0.5 - -self.height * 1, 1)--Lume.smooth(self.y, Game.HEIGHT * 0.5 - self.height * 0.5, dt * 10)
  --self.y = Lume.smooth(self.y, Game.HEIGHT * 0.5 - self.height * 0.5, dt * 14)

  self.lerpTimer = Lume.lerp(self.lerpTimer, 1, dt * 0.75)
  self.backgroundAlpha = Lume.lerp(self.backgroundAlpha, 0.45, self.lerpTimer * self.lerpTimer)

  self.back.y = self.y + self.height * 0.75
  self.next.y = self.y + self.height * 0.75
  self.redo.y = self.y + self.height * 0.75

  self.timer = Lume.lerp(self.timer, 0, dt * 3)
end

function Win:reset()
  --timer8 = 0
  self.scoreY = 0
  self.scoreText = SCORE_KEYS[1]

  self.incrementInter = false

  self.score = 0
  self.timer = 3
  --self.y = -self.height * 2
  self.next.y = self.y
  self.back.y = self.y
  self.redo.y = self.y
  self.lerpTimer = 0
  self.backgroundAlpha = 0
  self.savedData = false
  self.playedJingle = false

  self.confettiTimer = 0
  self.confettiCalls = 0

  self.scale = 0
  self.scaleTimer = 0

  for i = 1, #self.scoreBoxes do
    self.scoreBoxes[i].offset = 0
    self.scoreBoxes[i].scale = 0
    self.scoreBoxes[i].scaleTimer = 0
    self.scoreBoxes[i].playedPop = false
  end

  for i = #Confetti, 1, -1 do
    table.remove(Confetti, i)
  end
end

function Win:determineScore()

  if(not self.playedJingle and Save.saveData.sounds) then
    Loader.sfx["Win"]:stop()
    Loader.sfx["Win"]:play()
    self.playedJingle = true
  end

  self.score = 1

  if(World.moves <= World.minMoves) then
    self.score = 3
  else
    if(World.moves <= World.minMoves + Lume.round(World.minMoves * 0.2)) then
      self.score = 2
    end
  end

  self.scoreText = SCORE_KEYS[self.score]

  if(World.currentLevel.rating < self.score) then

    World.currentLevel.rating = self.score

    if(not self.savedData) then
      Save.saveData.levelData[World.currentLevel.fileIndex].score = self.score
      self.savedData = true
      Slib:save(Save.saveData)
    end

  end

end
