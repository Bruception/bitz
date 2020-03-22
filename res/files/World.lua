
local lg = love.graphics

World = {}

function World:load()

  self.pauseCanvas = lg.newCanvas(Game.WIDTH, Game.HEIGHT)

  self.numStacks = 4

  self.pause = false

  self.messageTimer = 0
  self.messageScale = 0

  PauseWindow:load()
  Confetti:load()

  self.pauseAlpha = 0

  self.gameOver = false
  self.lerpTimer = 0
  self.lerpTimer2 = 0
  self.messageAlpha = 1

  self.movesScale = 0
  self.movesTimer = 0

  self.stackUpdateTimer = 0

  self.tapped = false

  self.shakeAmount = 0
  self.shakeTimer = 0
  self.initShake = false

  self.winCondition = {0, 0, 0, 0}

  self.winTimer = 0

  self.message = ""
  self.minMoves = 0
  self.moves = 0

  self.currentLevel = LevelSelect.levels[1]

  self.back = Button:new({
    color = Game.colorPal1:getColor("teal"),
    colorHover = Game.colorPal2:getColor("teal"),
    imageColor = Game.colorPal1:getColor("white"),
    x = Game.WIDTH * 0.85 - Game.WIDTH * 0.1125 * 0.5,
    y = Game.HEIGHT * 0.2,
    width = Game.WIDTH * 0.1125,
    height = Game.WIDTH * 0.1125,
    text = "",
    image = Loader.gfx["pause"],
    paddingX = 0.2,
    paddingY = 0.2,
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      self.pause = true
    end
  })

  self.redo = Button:new({
    color = Game.colorPal1:getColor("yellow"),
    colorHover = Game.colorPal2:getColor("yellow"),
    imageColor = Game.colorPal1:getColor("white"),
    width = Game.WIDTH * 0.1125,
    height = Game.WIDTH * 0.1125,
    text = "",
    paddingX = -0.2,
    paddingY = -0.2,
    image = Loader.gfx["redo"],
    y = Game.HEIGHT * 0.2,
    x = Game.WIDTH * 0.15 - Game.WIDTH * 0.1125 * 0.5,

    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      local temp = self.currentLevel

      self:softReset()
      LevelLoader:initParse(self.currentLevel.file)

      self.currentLevel = temp
    end

  })

  Block:load()

  self.stacks = {}
  self.blocks = {}

  local offsetY = Game.HEIGHT * .075
  local offsetX = Game.WIDTH * .035

  local intervalPosX = Game.WIDTH / 3
  local intervalPosY = Game.HEIGHT / 3

  local x = 0.8
  local y = 0.75

  for i = 1, 4 do
    self.stacks[i] = Stack:new({
      x = offsetX + (intervalPosX * x) - Game:scaleWidth(120 * 0.85) * 0.5,
      y = offsetY + (intervalPosY * y) - Game:scaleWidth(180 * 0.85) * 0.5
    })
    x = x + 1.2

    if(x >= 3) then
      x = 0.8
      y = y + .95
    end
  end

  LevelLoader:initParse("l00.stack")

end

function World:update(dt)

  if(self.numStacks == 3) then
    self.stacks[3].x = Game.WIDTH * 0.5 - self.stacks[3].width * 0.5
  else
    self.stacks[3].x = (Game.WIDTH * .035) + ((Game.WIDTH / 3) * 0.8) - Game:scaleWidth(120 * 0.85) * 0.5
  end

  self:animate(dt)

  if(self.tapped) then
    self.lerpTimer = Lume.lerp(self.lerpTimer, 1, dt * 0.12)
    self.messageAlpha = Lume.lerp(self.messageAlpha, 0, self.lerpTimer * self.lerpTimer)
  end

  self.stackUpdateTimer = Lume.lerp(self.stackUpdateTimer, self.numStacks, dt * 6)

  for i = 1, 4 do
    self.stacks[i]:update(dt)
  end

  lg.setBlendMode("add")
  for i = 1, #Dust do
    Dust[i]:update(dt)
  end
  lg.setBlendMode("alpha")

  for i = 1, Lume.roundP(self.stackUpdateTimer) do
    self.stacks[i]:animate(dt)
  end

  if(self.pause and self:checkWin()) then
    self.pause = false
  end

  if(not self.gameOver and not self.pause) then

    if(self.initShake) then
      self:shake(dt)
    else
      self.shakeAmount = Lume.smooth(self.shakeAmount, 0, dt * 4)
    end

    Pointer:update(dt)
    self.gameOver = self:checkWin()

    if(BLOCK_TOUCHED == 0) then
      self.back:update(dt)
      self.redo:update(dt)
    end

    for i = 1, #self.blocks do
      self.blocks[i]:update(dt)
    end
  elseif(self.gameOver and not self.pause) then
    Pointer:reset()
    self.winTimer = self.winTimer + dt
    if(self.winTimer >= 0.5) then
      Win:update(dt)
    end
  end

end

local fontW
local fontH

function World:draw()

  if(self.pause or self.gameOver) then
    lg.setCanvas(self.pauseCanvas)
    lg.clear()
    lg.setShader(Gradient)
    lg.draw(Game.background)
    lg.setShader()
  end

  lg.setColor(Game.colorPal2:getColor("gray"))

  for i = 1, 4 do
    self.stacks[i]:draw()
  end

  if(BLOCK_TOUCHED == 0) then
    for i = 1, #self.blocks do
      self.blocks[i]:draw()
    end
  else

    for i = 1, #self.blocks do
      if(self.blocks[i] ~= BLOCK_TOUCHED) then
        self.blocks[i]:draw()
      end
    end

    BLOCK_TOUCHED:draw()
  end

  for i = 1, #Dust do
    Dust[i]:draw()
  end
  --lg.setColor(Game.colorPal1:getColor("black"))
--  lg.rectangle("line", Game.WIDTH * 0.05, Game.HEIGHT * 0.15, Game.WIDTH * 0.9, Game.HEIGHT * 0.8, 10, 10)

  lg.setFont(Menu.testFont)
  if(not self.gameOver) then

    lg.push()

    lg.translate(Game.WIDTH * 0.5, Game.HEIGHT * 0.5)
    lg.scale(self.messageScale, 1)
    lg.translate(-Game.WIDTH * 0.5, -Game.HEIGHT * 0.5)


    lg.setColor(Game.colorPal1:getColor("white")[1], Game.colorPal1:getColor("white")[2], Game.colorPal1:getColor("white")[3], self.messageAlpha)

    fontW = Menu.testFont:getWidth(self.message) * 0.5
    fontH = Menu.testFont:getHeight(self.message) * 0.5
    lg.print(self.message, Game.WIDTH * 0.5 - fontW, Game.HEIGHT * 0.2 - fontH)
    lg.pop()
  end


  lg.setColor(Game.colorPal1:getColor("white"))

  lg.setScissor(0, 0, Game.WIDTH, Game.HEIGHT * .15)

  lg.push()

  lg.translate(Game.WIDTH * 0.5, Game.HEIGHT * 0.5)
  lg.scale(self.movesScale, 1)
  lg.translate(-Game.WIDTH * 0.5, -Game.HEIGHT * 0.5)

  fontW = Menu.testFont:getWidth(self.moves .. "   /   " .. self.minMoves) * 0.5
  fontH = Menu.testFont:getHeight(self.moves .. "   /   " .. self.minMoves) * 0.2
  lg.print(self.moves .. "   /   " .. self.minMoves, Game.WIDTH * 0.5 - fontW + self.shakeAmount, self.back.y + fontH)

  lg.pop()


  self.back:draw()
  self.redo:draw()

  lg.setScissor()

  Pointer:draw()

  if(self.pause or self.gameOver) then
    lg.setCanvas()
    lg.setShader(Blur)
    lg.draw(self.pauseCanvas)
    lg.setShader()
  end

  if(self.pause) then
    lg.setColor(0, 0, 0, self.pauseAlpha)
    lg.rectangle("fill", 0, 0, Game.WIDTH, Game.HEIGHT)
    PauseWindow:draw()
  end

  if(self.gameOver) then
    Win:draw()
  end

end

function World:touchReleased(id, x, y)
  if(not self.gameOver and not self.pause) then
    self.tapped = true
    for i = 1, #self.blocks do
      self.blocks[i]:touchReleased(id, x, y)
    end

    if(BLOCK_TOUCHED == 0) then
      self.redo:touchReleased(id)
      self.back:touchReleased(id)
    end
  elseif(self.gameOver and not self.pause) then
    Win:touchReleased(id)
  elseif(not self.gameOver and self.pause) then
    PauseWindow:touchReleased(id)
  end

end

function World:reset()
  self.movesScale = 0
  self.movesTimer = 0

  self.numStacks = 4
  self.messageTimer = 0
  self.messageScale = 0
  self.stackUpdateTimer = 0
  self.currentLevel = LevelSelect.levels[1]
  self.messageAlpha = 1
  self.winTimer = 0
  self.lerpTimer = 0
  self.shakeAmount = 0
  self.shakeTimer = 0
  self.initShake = false
  self.tapped = false
  self.gameOver = false

  self.pauseAlpha = 0
  self.lerpTimer2 = 0
  self.pause = false

  self.redo.y = Game.HEIGHT * 0.25
  self.back.y = Game.HEIGHT * 0.25

  self.message = ""
  self.moves = 0
  self.minMoves = 0

  for i = #self.blocks, 1, -1 do
    table.remove(self.blocks, i)
  end
  for i = 1, #self.stacks do
    self.winCondition[i] = 0
    self.stacks[i]:clear()
  end
end

function World:softReset()
  self.movesScale = 0
  self.movesTimer = 0

  self.numStacks = 4
  self.messageTimer = 0
  self.messageScale = 0
  self.stackUpdateTimer = 0
  self.winTimer = 0
  self.messageAlpha = 1
  self.lerpTimer = 0
  self.shakeAmount = 0
  self.shakeTimer = 0
  self.tapped = false
  self.initShake = false

  self.pauseAlpha = 0
  self.lerpTimer2 = 0
  self.pause = false

  self.gameOver = false

  self.message = ""
  self.moves = 0
  self.minMoves = 0

  self.redo.y = Game.HEIGHT * 0.25
  self.back.y = Game.HEIGHT * 0.25

  for i = #self.blocks, 1, -1 do
    table.remove(self.blocks, i)
  end
  for i = 1, #self.stacks do
    self.winCondition[i] = 0
    self.stacks[i]:clear()
  end
end

function World:startShake()
  self.initShake = true
  self.shakeTimer = 0
end

function World:shake(dt)
  self.shakeTimer = self.shakeTimer + dt

  if(self.shakeTimer < .5) then
    self.shakeAmount = 4 * math.sin(48 * self.shakeTimer)
  else
    self.initShake = false
  end
end

function World:incrementMoves()
  self.movesScale = 0
  self.movesTimer = 0
  self.moves = self.moves + 1
end
local bAmount = 0

function World:animate(dt)

  if(self.pause or self.gameOver) then
    Blur:send("blurAmount", bAmount)
    bAmount = Lume.lerp(bAmount, 0.0016, dt)
  else
    bAmount = 0.00001
  end

  if(self.pause) then
    self.lerpTimer2 = Lume.lerp(self.lerpTimer2, 1, dt * 0.75)
    self.pauseAlpha = Lume.lerp(self.pauseAlpha, 0.45, self.lerpTimer2 * self.lerpTimer2)
    PauseWindow:update(dt)
  else
    self.lerpTimer2 = 0
    self.pauseAlpha = Lume.smooth(self.pauseAlpha, 0, dt * 16)
  end

  if(not self.gameOver) then
    self.redo.y = Lume.smooth(self.redo.y, Game.HEIGHT * 0.1 - (Game.HEIGHT * 0.05) * 0.5, dt * 16)
    self.back.y = self.redo.y--Lume.smooth(self.back.y, Game.HEIGHT * 0.1 - (Game.HEIGHT * 0.05) * 0.5, dt * 16)
    self.redo.x = (Game.WIDTH * 0.15 - Game.WIDTH * 0.1 * 0.5) + self.shakeAmount
    self.back.x = (Game.WIDTH * 0.85 - Game.WIDTH * 0.1 * 0.5) + self.shakeAmount
  else
    self.redo.y = Lume.smooth(self.redo.y, Game.HEIGHT * 0.25, dt * 8)
    self.back.y = self.redo.y--Lume.smooth(self.back.y, Game.HEIGHT * 0.25, dt * 8)
  end

  self.messageTimer = Lume.lerp(self.messageTimer, 1, dt * 2)
  self.messageScale = Lume.outElastic(self.messageTimer, 0, 1, 1)

  self.movesTimer = Lume.lerp(self.movesTimer, 1, dt)
  self.movesScale = Lume.outElastic(self.movesTimer, 0, 1, 1)

  for i = 1, #self.blocks do
    self.blocks[i]:animate(dt)
  end
end

function World:checkWin()
  local count = 0

  for i = 1, #self.stacks do
    if(self.stacks[i]:hasDesiredWeight()) then
      count = count + 1
    end
  end

  return (count == 4) and true or false
end
