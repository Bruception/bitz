
local lg = love.graphics

Toast = {}

Toast.__index = Toast

local MESSAGE_TYPE_KEY = {
  ["ERROR"] = "red",
  ["NEUTRAL"] = "blue",
  ["GOOD"] = "green"
}

function Toast:new(properties)
  local self = {}

  self.text = properties.text or "Test"

  self.timer = 0

  self.width = Game.WIDTH
  self.height = Game.WIDTH * 0.15

  self.messageType = properties.messageType or "NEUTRAL"

  self.primColor = Game.colorPal1:getColor(MESSAGE_TYPE_KEY[self.messageType])
  self.seconColor = Game.colorPal2:getColor(MESSAGE_TYPE_KEY[self.messageType])

  self.x = 0
  self.y = -self.height * 2

  self.timer = 0
  self.expired = false

  self.remove = false

  return setmetatable(self, Toast)
end

function Toast:update(dt)

  self.timer = self.timer + dt

  if(self.timer >= 3 and self.y + self.height >= 0) then
    self.expired = true
  end

  if(self.expired) then
    self.y = Lume.lerp(self.y, -self.height * 2, dt * 6)
  else
    self.y = Lume.lerp(self.y, 0 + top, dt * 4)
  end

  if(self.y + self.height < 0 and self.expired) then
    self.remove = true
  end

end

function Toast:draw()
  lg.setColor(self.primColor)
  lg.rectangle("fill", self.x, self.y, self.width, self.height)
  lg.setColor(self.seconColor)
  lg.setFont(Menu.testFont)
  local fontW = Menu.testFont:getWidth(self.text)
  local fontH = Menu.testFont:getHeight(self.text)
  lg.print(self.text, self.x + self.width * 0.5 - fontW * 0.5, self.y + self.height * 0.5 - fontH * 0.4)
end

function Toast:checkCollision(x, y)
  return (x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height)
end
