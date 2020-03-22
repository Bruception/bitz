
local lg = love.graphics
local random, sin, cos = math.random, math.sin, math.cos

Confetti = {}

Confetti.__index = Confetti

local COLOR_LIST = {}
function Confetti:load()
  COLOR_LIST[1] = Game.colorPal1:getColor("blue")
  COLOR_LIST[2] = Game.colorPal1:getColor("orange")
  COLOR_LIST[3] = Game.colorPal1:getColor("red")
  COLOR_LIST[4] = Game.colorPal1:getColor("green")
  COLOR_LIST[5] = Game.colorPal1:getColor("purple")
  COLOR_LIST[6] = Game.colorPal1:getColor("yellow")
end

function Confetti:new(properties)
  local self = {}

  self.x = properties.x
  self.y = properties.y

  local colorIndex = random(#COLOR_LIST)

  self.color = COLOR_LIST[colorIndex]

  self.remove = false

  self.height = random(Game:scaleWidth(2.5), Game:scaleWidth(5))
  self.width = Game:scaleWidth(15)

  self.oWidth = self.width
  self.oHeight = self.height

  self.height = self.height * 1.5
  self.width = self.width * 2

  self.angle = properties.angle + math.random(-10, 10) * 0.025
  self.angle2 = self.angle
  self.oAngle = self.angle
  self.phase = random(1, 10)

  self.anglePeriod = random(2, 5)

  self.amp = random(25, 100)
  self.periodMult = random(1, 4)
  self.angleMult = random(6, 12)
  self.randomAmp = random(10, 200) * 0.01

  self.randomMult = random(10, 50) * 0.1

  self.timer = 0

  self.velY = random(600, 200)

  self.velX = properties.velX

  return setmetatable(self, Confetti)
end

function Confetti:update(dt)

  self.phase = self.phase + dt
  self.timer = self.timer + dt

  self.velY = Lume.lerp(self.velY, 200, dt * self.randomMult)--self.speed - 8 * dt
  self.velX = Lume.lerp(self.velX, 0, dt * 4)

  if(self.timer <= dt * 4) then
    self.width = Lume.lerp(self.width, self.oWidth, dt * 4)
    self.height = Lume.lerp(self.height, self.oHeight, dt * 4)
  end

  self.width = self.oWidth + self.oWidth * 0.5 * math.cos(self.phase)
  self.height = self.oHeight + self.oHeight * 0.5 * math.sin(self.phase)

  self.angle = Lume.smooth(self.angle, self.angle + sin(self.anglePeriod * self.phase) * self.randomAmp, dt * self.angleMult)
  self.angle2 = Lume.smooth(self.angle2, 0, dt * 0.1)

  self.y = self.y + self.velY * sin(self.angle2) * dt
  self.x = self.x + self.velX * cos(self.angle) * dt

  self.x = self.x + self.amp * cos(self.periodMult * self.phase) * dt

  if(self.y > Game.HEIGHT) then
    self.remove = true
  end
end

function Confetti:draw()

  lg.push()

  lg.translate(self.x + self.width * 0.5, self.y + self.height * 0.5)
  lg.rotate(self.angle)
  lg.translate(-self.x - self.width * 0.5, -self.y - self.height * 0.5)

  lg.setColor(self.color[1], self.color[2], self.color[3])
  lg.rectangle("fill", self.x, self.y, self.width, self.height)

  lg.pop()
end
