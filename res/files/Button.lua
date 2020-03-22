
local lg = love.graphics
local lt = love.touch

Button = {}

Button.__index = Button

function Button:new(properties)

  properties = properties or {
    x = 0,
    y = 0,
    width = lg:getWidth() * 0.5,
    height = lg:getHeight() * 0.1,
    roundness = 10,
    color = {1, 1, 1},
    alpha = 1,
    func = function() print("Hello World!") end,
    enabled = true
  }

  local self = {}

  --------------- STYLISTIC PROPERTIES -------------------
  self.x = properties.x or 0
  self.y = properties.y or 0

  self.width = properties.width or lg:getWidth() * 0.5
  self.height = properties.height or lg:getHeight() * 0.1

  self.roundness = properties.roundness or 10

  self.color = properties.color or {1, 1, 1}
  self.textColor = properties.textColor or {1, 1, 1}
  self.imageColor = properties.imageColor or {1, 1, 1}
  self.colorHover = properties.colorHover or {0.5, 0.5, 0.5}

  self.alpha = properties.alpha or 1

  self.text = properties.text or "Button"

  self.image = properties.image or nil

  self.paddingX = properties.paddingX or 0
  self.paddingY = properties.paddingY or 0

  self.imageOffsetY = properties.imageOffsetY or 0
  self.imageOffsetX = properties.imageOffsetX or 0

  self.imageAngle = 0

  if(self.image ~= nil) then
    self.imageScaleX = (self.width / self.image:getWidth()) * (0.65 - self.paddingX)
    self.imageScaleY = (self.height / self.image:getHeight()) * (0.65 - self.paddingY)
    self.imageWidth = self.image:getWidth() * self.imageScaleX
    self.imageHeight = self.image:getHeight() * self.imageScaleY
  end

  self.shadowScaleX = (self.width / Loader.gfx["boxshadow"]:getWidth()) * 1.6
  self.shadowScaleY = (self.height / Loader.gfx["boxshadow"]:getHeight()) * 1.6
  self.shadowOffsetX = -self.width * 0.3
  self.shadowOffsetY = -self.height * 0.1
  self.shadowIntensity = 0.3

  --------------- FUNCTIONAL PROPERTIES -------------------
  self.visible = true
  self.touchId = 0
  self.touched = false
  self.enabled = properties.enabled or true

  self.offset = self.height * 0.05

  self.func = properties.func or function() print("Hello World!") end

  return setmetatable(self, Button)

end

function Button:update(dt)
  self.touched = self:getTouch()
  if(not self.touched) then
    self.offset = Lume.smooth(self.offset, self.height * 0.05 , dt * 28)
  else
    self.offset = Lume.smooth(self.offset, 0, dt * 22)
  end
end


function Button:draw()

  if(self.visible) then
    lg.setColor(0, 0, 0, self.shadowIntensity)
    lg.draw(Loader.gfx["boxshadow"], self.x + self.shadowOffsetX, self.y + self.shadowOffsetY, 0, self.shadowScaleX, self.shadowScaleY)

    lg.setColor(self.colorHover[1], self.colorHover[2], self.colorHover[3], self.alpha)
    lg.rectangle("fill", self.x, self.y + self.height * 0.55, self.width, self.height * 0.5, self.roundness, self.roundness)

    if(self.enabled) then
      lg.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
    else
      self.offset = 0
      lg.setColor(self.colorHover[1], self.colorHover[2], self.colorHover[3], self.alpha)
    end

    lg.rectangle("fill", self.x, self.y + (self.height * 0.05 - self.offset), self.width, self.height * 0.9525, self.roundness, self.roundness)


    local font = lg:getFont()
    local fontH = font:getHeight(self.text)
    local textY = (self.y + self.height * 0.5) - fontH * 0.35

    lg.setColor(self.textColor[1], self.textColor[2], self.textColor[3], self.alpha)

    lg.printf(self.text, self.x, textY - self.offset, self.width, "center")

    if(self.image ~= nil) then
      lg.setColor(self.colorHover[1], self.colorHover[2], self.colorHover[3], 0.5)
      lg.draw(self.image, self.x + self.imageOffsetX + self.width * 0.5 - self.imageWidth * 0.5, (self.y + self.imageOffsetY + self.height * 0.5 - self.imageHeight * 0.5) + 2.5 - self.offset, 0, self.imageScaleX, self.imageScaleY)
      lg.setColor(self.imageColor[1], self.imageColor[2], self.imageColor[3], self.alpha)
      lg.draw(self.image, self.x + self.imageOffsetX + self.width * 0.5 - self.imageWidth * 0.5, (self.y + self.imageOffsetY + self.height * 0.5 - self.imageHeight * 0.5) - self.offset, 0, self.imageScaleX, self.imageScaleY)
    end
  end
end

function Button:getTouch()
  local touches = lt.getTouches()

  for i, id in ipairs(touches) do
    local x, y = lt.getPosition(id)
    if(self:isTouching(x, y) and self.enabled) then
      self.touchId = id
      return true
    end
  end
  return false
end

function Button:touchReleased(id)
  if(self.touched and id == self.touchId and self.enabled) then
    self.func()
  end
end

function Button:isTouching(x, y)
  return (x > self.x
    and x < self.x + self.width
    and y > self.y
    and y < self.y + self.height)
end

function Button:setAlpha(amount)
  self.alpha = amount
end
