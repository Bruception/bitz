
local lg = love.graphics

Dust = {}

Dust.__index = Dust

function Dust:new (properties)
  local self = {}

  self.x = properties.x
  self.y = properties.y
  self.size = 0
  self.alpha = 1

  self.dir = properties.dir--math.random(-math.pi, 0)
  self.dirSign = (self.dir > -math.pi * 0.5) and 1 or -1

  self.timer = math.random(10, 25) * 0.01
  self.sizeAmp = Game:scaleWidth(math.random(12, 18))
  self.alphaTimer = 0
  self.remove = false

  self.velX = math.random(50, 100)
  self.velY = math.random(50, 100)

  return setmetatable(self, Dust)
end

function Dust:update (dt)
  self.timer = self.timer + dt * 3.5
  self.alphaTimer = self.alphaTimer + dt * 3.5

  self.x = self.x + self.velX * math.cos(self.dir) * dt
  self.y = self.y + self.velY * math.sin(self.dir) * dt

  self.dir = self.dir + (self.dirSign) * dt

  self.size = self.sizeAmp * self:quadLerp(self.timer)
  self.alpha = self:quadLerp(self.alphaTimer)--Lume.smooth(self.alpha, 0, dt * 8)

  if(self.timer >= 1) then
    self.remove = true
  end
end

function Dust:draw ()

  lg.push()
  lg.translate(self.x, self.y)
  lg.rotate(self.dir)
  lg.translate(-self.x, -self.y)


  lg.setColor(Game.colorPal1:getColor("white")[1], Game.colorPal1:getColor("white")[2], Game.colorPal1:getColor("white")[3], self.alpha)
  lg.rectangle("fill", self.x, self.y, self.size, self.size * 0.2)
  lg.pop()
end

function Dust:quadLerp(time)
  time = Lume.clamp(time, 0, 1)

  local f = ( -4 * (time * time) ) + ( 4 * (time) )

  return f
end
