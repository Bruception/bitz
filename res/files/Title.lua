
local lg = love.graphics
local sin = math.sin

local Letter = {}

Letter.__index = Letter

function Letter:new(properties)
  local self = {}

  self.x = properties.x
  self.y = properties.y
  self.color = properties.color
  self.colorShadow = properties.colorShadow

  self.letter = properties.letter

  self.width = properties.width
  self.height = properties.height

  self.alpha = 0
  self.amp = 50

  self.timer = properties.timer

  self.offsetY = 0

  return setmetatable(self, Letter)
end

function Letter:update(dt)
  self.timer = self.timer + dt
  self.amp = Lume.lerp(self.amp, 5, dt)
  self.offsetY = Game:scaleHeight(self.amp) * sin(1.5 * self.timer)
end

function Letter:draw()
  lg.setColor(self.colorShadow[1], self.colorShadow[2], self.colorShadow[3], self.alpha)
  lg.print(self.letter, self.x, self.y + self.offsetY + Game:scaleHeight(3.5))
  lg.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
  lg.print(self.letter, self.x, self.y + self.offsetY)
  lg.setColor(1, 1, 1, 1)
end


Title = {}

function Title:load()

  self.letters = {}
  self.title = "bitz"

  self.titleFont = lg.newFont("res/fonts/BloggerSans.otf", Game:scaleWidth(125))

  self.x = Game.WIDTH * 0.5 - self.titleFont:getWidth(self.title) * 0.5
  self.y = Game.HEIGHT * 0.165

  self.alpha = 0

  self.colors = {
   Game.colorPal1:getColor("blue"),
   Game.colorPal1:getColor("orange"),
   Game.colorPal1:getColor("red"),
   Game.colorPal1:getColor("green")
  }

  self.colors2 = {
   Game.colorPal2:getColor("blue"),
   Game.colorPal2:getColor("orange"),
   Game.colorPal2:getColor("red"),
   Game.colorPal2:getColor("green")
  }

  self.letterX = 0

  local letterWidth = 0
  local letterHeight = 0

  self.width = 0
  self.height = 0

  for i = 1, 4 do

    letterWidth = self.titleFont:getWidth(string.sub(self.title, i, i))
    letterHeight = self.titleFont:getHeight(string.sub(self.title, i, i))

    self.letters[#self.letters + 1] = Letter:new({
      x = self.x + self.letterX,
      y = self.y,
      color = self.colors[i],
      colorShadow = self.colors2[i],
      letter = string.sub(self.title, i, i),
      width = letterWidth,
      height = letterHeight,
      timer = math.pi * 0.5 + (i * math.pi * 0.25)
    })
    self.width = self.width + letterWidth
    self.height = letterHeight
    self.letterX = self.letterX + letterWidth
  end

  self.titleScale = 0
  self.titleTimer = 0

end
function Title:update(dt)
  if(self.alpha >= dt) then
    self.titleTimer = Lume.lerp(self.titleTimer, 1, dt * 0.5)
    self.titleScale = Lume.outElastic(self.titleTimer, 0, 1, 1)
  end
  for i = 1, 4 do
    self.letters[i]:update(dt)
  end
end

function Title:draw()

  lg.push()

  lg.translate(Game.WIDTH * 0.5, Game.HEIGHT * 0.5)
  lg.scale(self.titleScale)
  lg.translate(-Game.WIDTH * 0.5, -Game.HEIGHT * 0.5)

  lg.setFont(self.titleFont)
  for i = 1, 4 do
    self.letters[i].alpha = self.alpha
    self.letters[i]:draw()
  end

  lg.pop()
end

function Title:reset()
  self.alpha = 0
  self.titleScale = 0
  self.titleTimer = 0
  for i = 1, 4 do
    self.letters[i].timer = math.pi * 0.5 + (i * math.pi * 0.25)
    self.letters[i].amp = 50
  end
end
