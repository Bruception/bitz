
local lg = love.graphics
local lt = love.touch
local ls = love.system

BLOCK_TOUCHED = 0

Block = {}

local BLUE_FONT, ORANGE_FONT, RED_FONT, GREEN_FONT

local ORDER = {
  "gray",
  "blue",
  "orange",
  "red",
  "green"
}

local WEIGHT_KEYS = {
  ["0"] = 1,
  ["3"] = 2,
  ["4"] = 3,
  ["5"] = 4,
  ["6"] = 5
}

function Block:load()
  BLUE_FONT = lg.newFont("res/fonts/BloggerSans.otf", Game:scaleWidth(20 * 0.85))
  ORANGE_FONT = lg.newFont("res/fonts/BloggerSans.otf", Game:scaleWidth(24 * 0.85))
  RED_FONT = lg.newFont("res/fonts/BloggerSans.otf", Game:scaleWidth(32 * 0.85))
  GREEN_FONT = lg.newFont("res/fonts/BloggerSans.otf", Game:scaleWidth(40 * 0.85))
end

Block.__index = Block

function Block:new(properties)
  local self = {}

  self.x = properties.x
  self.y = properties.y
  self.type = properties.type

  self.startY = self.y

  self.color = 0
  self.weight = 0
  self.pos = 1

  self.dustAnimation = false
  self.d = false

  self.squeezeTimer = 0
  self.squeezeScale = 0.75

  if(self.type == "blue") then
    self.weight = 3
    self.font = BLUE_FONT
  elseif(self.type == "orange") then
    self.weight = 4
    self.font = ORANGE_FONT
  elseif(self.type == "red") then
    self.weight = 5
    self.font = RED_FONT
  elseif(self.type == "green") then
    self.weight = 6
    self.font = GREEN_FONT
  elseif(self.type == "gray") then
    self.weight = 0
    self.font = GREEN_FONT
  elseif(self.type == "purple") then
    self.weight = 0
    self.font = BLUE_FONT
  elseif(self.type == "yellow") then
    self.weight = 0
    self.font = BLUE_FONT
  end

  self.angle = math.random(-20, 20) * .01

  if(self.type == "purple") then
    self.fontWidth = self.font:getWidth("x 2")
    self.fontHeight = self.font:getHeight("x 2")
  elseif(self.type == "yellow") then
    self.fontWidth = self.font:getWidth("x 2")
    self.fontHeight = self.font:getHeight("x 2")
  else
    self.fontWidth = self.font:getWidth(self.weight)
    self.fontHeight = self.font:getHeight(self.weight)
  end

  self.color = Game.colorPal1:getColor(self.type)
  self.colorShadow = Game.colorPal2:getColor(self.type)

  self.size = Game:scaleWidth((self.weight * 20)* 0.85)

  if(self.type == "purple" or self.type == "yellow") then
    self.size = Game:scaleWidth((2.5 * 20) * 0.85)
  elseif(self.type == "gray") then
    self.size = Game:scaleWidth((2.5 * 20) * 0.85)
    self.cycle = 1
  end

  self.height = (Game:scaleHeight(180 * 0.85) * 0.22)--self.size * 0.75--Game:scaleWidth(45)

  self.offset = self.height * 0.05

  self.shadowScaleX = (self.size / Loader.gfx["boxshadow"]:getWidth()) * 1.6
  self.shadowScaleY = (self.height / Loader.gfx["boxshadow"]:getHeight()) * 1.6
  self.shadowOffsetX = -self.size * 0.3
  self.shadowOffsetY = -self.height * 0.1
  self.shadowIntensity = 0.3

  self.stack = nil
  self.newStack = -1


  self.colX = 0
  self.colY = 0


  ---- FUNCTIONAL PROPERTIES -----------
  self.touched = false
  self.locationTouchedX = self.x
  self.locationTouchedY = self.y
  self.startLocationX = self.x
  self.startLocationY = self.y
  self.touchId = nil
  self.timer = 0

  return setmetatable(self, Block)

end

function Block:update(dt)

  if(self.touched and BLOCK_TOUCHED == self) then
    self.offset = Lume.smooth(self.offset, self.height * 0.05 , dt * 28)
  else
    self.offset = Lume.smooth(self.offset, 0, dt * 22)
  end

  self:handleTouches(dt)
  self:collideWithWalls()
  self:collideWithStacks()

end

function Block:draw()

  lg.push()

  lg.translate(self.stack.squeezePivotX, self.stack.squeezePivotY)
  lg.scale(1 + (1 - self.stack.squeezeScale), self.stack.squeezeScale)
  lg.translate(-self.stack.squeezePivotX, -self.stack.squeezePivotY)

  lg.push()

  lg.translate(self.x + self.size * 0.5, self.y + self.size * 0.5)

  lg.rotate(self.angle)

  lg.translate(-self.x - self.size * 0.5, -self.y - self.size * 0.5)

  lg.setColor(0, 0, 0, self.shadowIntensity)
  lg.draw(Loader.gfx["boxshadow"], self.x + self.shadowOffsetX, self.y + self.shadowOffsetY, 0, self.shadowScaleX, self.shadowScaleY)

  lg.setColor(self.colorShadow[1], self.colorShadow[2], self.colorShadow[3], 1)
  lg.rectangle("fill", self.x, self.y + self.height * 0.5, self.size, self.height * 0.5, 10, 10)

  lg.setColor(self.color[1], self.color[2], self.color[3])
  lg.rectangle("fill", self.x, self.y - (self.height * 0.05 - self.offset), self.size, self.height * 0.925, 10, 10)

  lg.setFont(self.font)
  lg.setColor(Game.colorPal1:getColor("white"))

  if(self.type == "purple") then
    lg.print("x 2", self.x + self.size * 0.5 - self.fontWidth * 0.5, (self.y + (self.height * 0.85 * 0.5) - (self.fontHeight * 0.4)) + self.offset)
  elseif(self.type == "yellow") then
    Obelus:draw(self.x + self.size * 0.3125, self.y + self.height * 0.41525 + self.offset, 0.125, 0.125)
    lg.print("  2", self.x + self.size * 0.5 - self.fontWidth * 0.5, (self.y + (self.height * 0.85 * 0.5) - (self.fontHeight * 0.4)) + self.offset)
  else
    lg.print(self.weight, self.x + self.size * 0.5 - self.fontWidth * 0.5, (self.y + (self.height * 0.85 * 0.5) - (self.fontHeight * 0.4)) + self.offset)
  end

  --lg.rectangle("line", self.x - self.colX * 0.5, self.y - self.colY * 0.5, self.size + self.colX, self.height + self.colY)

  lg.pop()
  lg.pop()

end

function Block:handleTouches(dt)

  if(self:getTouches()) then
    if(not self.touched and BLOCK_TOUCHED == 0 and self.stack ~= nil and self.pos == #self.stack.blocks) then
      BLOCK_TOUCHED = self
      if(Save.saveData.hapticFeedback) then
        ls.hapticFeedback(0)
      end

      local x, y = 0, 0

      if(pcall(lt.getPosition, self.touchId)) then
        x, y = lt.getPosition(self.touchId)
      else
        self.touched = false
        return
      end

      self.touched = true
      self.locationTouchedX = x
      self.locationTouchedY = y
      self.startLocationX = self.x
      self.startLocationY = self.y

      self.colX = self.size * 6
      self.colY = self.height * 6

    end
  else
    self.colX = 0
    self.colY = 0
    self.touched = false
  end

  if(self.touched and BLOCK_TOUCHED == self) then
    local x, y = lt.getPosition(self.touchId)
    local dy, dx = (y - self.locationTouchedY), (x - self.locationTouchedX)

    self:setPosition(self.startLocationX + dx, self.startLocationY + dy)
  end
end

function Block:getTouches()
  local touches = lt.getTouches()

  for i, id in ipairs(touches) do
    local x, y = lt.getPosition(id)

    if(self:isTouching(x,y)) then
      self.touchId = id
      return true
    end
  end
  return false
end

function Block:setPosition(x, y)
  self.x = x
  self.y = y
end

function Block:isTouching(x, y)
  return (x > self.x - self.colX * 0.5
    and x < self.x + self.size + self.colX
    and y > self.y - self.colY * 0.5
    and y < self.y + self.height + self.colY)
end

function Block:touchReleased(id, x, y)

  if(id == self.touchId and BLOCK_TOUCHED == self and self.type == "gray") then

    local dist = Lume.distance(self.x, self.y, self.startLocationX, self.startLocationY, false)

    if(dist <= self.size * 0.05 and self.newStack ~= -1 and World.stacks[self.newStack] == self.stack and self.startLocationX) then
      if(#self.stack.blocks == 1) then

        self.cycle = self.cycle + 1

        self.cycle = (self.cycle < 6) and self.cycle or 1

        self:setIdentity(ORDER[self.cycle])

      else
        local previousWeight = self.stack:getPreviousWeight(self.pos)
        local maxIndex = WEIGHT_KEYS[tostring(previousWeight)]

        self.cycle = self.cycle + 1

        self.cycle = (self.cycle < maxIndex + 1) and self.cycle or 1
        self:setIdentity(ORDER[self.cycle])
      end
    end
  end

  if(id == self.touchId and BLOCK_TOUCHED == self and
      self.newStack ~= -1 and self.stack ~= World.stacks[self.newStack] and
      World.stacks[self.newStack]:checkWeight(self)) then

    if(Save.saveData.sounds) then
      local a = Loader.sfx["BlockDrop"]:play()
      local w = Lume.clamp(self.weight, 0, 6)
      a:setPitch(Lume.constraint(w, 0, 6, 1.1, 0.8))
    end

    if(Save.saveData.hapticFeedback) then
      local w = Lume.clamp(self.weight, 0, 6)

      ls.hapticFeedback(Lume.roundP(Lume.constraint(w, 0, 6, 0, 2), 0))
    end

    self.dustAnimation = false
    self.d = false

    World:incrementMoves()

    self.stack:remove(self)
    self.pos = 1
    World.stacks[self.newStack]:add(self)
    World.stacks[self.newStack].textTimer = 0
    World.stacks[self.newStack].textScale = 0
    World.stacks[self.newStack].squeezeTimer = 0
    self.stack = World.stacks[self.newStack]
    BLOCK_TOUCHED = 0

    self.timer = 0
    self.startY = y

    self.angle = math.random(-20, 20) * .01

  elseif (id == self.touchId and BLOCK_TOUCHED == self and self.newStack ~= -1 and self.stack ~= World.stacks[self.newStack] and not World.stacks[self.newStack]:checkWeight(self)) then
    World:startShake()
  end

  if(id == self.touchId and BLOCK_TOUCHED == self) then
    BLOCK_TOUCHED = 0
  end

end

function Block:collideWithStacks()
  for i = 1, 4 do
    if(self:checkCollision(World.stacks[i]) and i <= World.numStacks) then
      self.newStack = i

      return true
    end
  end
  self.newStack = -1
  return false
end

function Block:collideWithWalls()
  if(self.x < Game.WIDTH * 0.05) then
    self.x = Game.WIDTH * 0.05
    --if(self.stack ~= nil) then
    --end
  end
  if(self.x + self.size > Game.WIDTH * 0.95) then
    self.x = Game.WIDTH * 0.95 - self.size
  end

  if(self.y < Game.HEIGHT * 0.15) then
    self.y = Game.HEIGHT * 0.15
  end
  if(self.y + self.height > Game.HEIGHT * 0.95) then
    self.y = Game.HEIGHT * 0.95 - self.height
  end
end

function Block:checkCollision(stack)
  return (self.x + self.size > stack.x and
          self.x < stack.x + stack.width and
          self.y + self.height > stack.y and
          self.y < stack.y + stack.height)
end

function Block:donate()
  self.calledDonate = true
  self.weight = 0
  self.weight = self.stack.desiredWeight - self.stack:sumBlockWeights()
  self.fontWidth = self.font:getWidth(self.weight)
  self.fontHeight = self.font:getHeight(self.weight)
end

function Block:setIdentity(type)
  if(type == "blue") then
    self.weight = 3
    self.size = Game:scaleWidth((self.weight * 20) * 0.85)
  elseif(type == "orange") then
    self.weight = 4
    self.size = Game:scaleWidth((self.weight * 20) * 0.85)
  elseif(type == "red") then
    self.weight = 5
    self.size = Game:scaleWidth((self.weight * 20) * 0.85)
  elseif(type == "green") then
    self.weight = 6
    self.size = Game:scaleWidth((self.weight * 20) * 0.85)
  elseif(type == "gray") then
    self.weight = 0
    self.size = Game:scaleWidth((2.5 * 20) * 0.85)
  end

  if(Save.saveData.sounds) then
    local a = Loader.sfx["Tap"]:play()
    local w = Lume.clamp(self.weight, 3, 6)
    a:setPitch(Lume.constraint(w, 0, 6, 1.1, 0.9))
  end

  self.shadowScaleX = (self.size / Loader.gfx["boxshadow"]:getWidth()) * 1.6
  self.shadowScaleY = (self.height / Loader.gfx["boxshadow"]:getHeight()) * 1.6
  self.shadowOffsetX = -self.size * 0.3
  self.shadowOffsetY = -self.height * 0.1
  self.fontWidth = self.font:getWidth(self.weight)
  self.fontHeight = self.font:getHeight(self.weight)

  self.x = self.stack.x + self.stack.width * 0.5 - self.size * 0.5
end

function Block:animate (dt)
  self.angle = Lume.smooth(self.angle, 0, dt * 8)

  if(self.dustAnimation and not self.d) then
    local a = -math.pi
    for j = 1, 3 do
      Dust[#Dust + 1] = Dust:new({
        y = self.y + self.height,
        x = self.x,
        dir = -math.pi + j * 0.75
      })
    end
    a = 0
    for j = 1, 3 do
      Dust[#Dust + 1] = Dust:new({
        y = self.y + self.height,
        x = self.x + self.size,
        dir = 0 - j * 0.75
      })
    end
    self.d = true
  end
end
