
local lg = love.graphics

Obelus = {}

function  Obelus:load ()

  self.width = 128
  self.height = 128

  self.image = lg.newCanvas(self.width, self.height)

  lg.setCanvas(self.image)
  lg.clear()

  lg.setLineWidth(.5)

  lg.circle("fill", self.width * 0.5, self.height * 0.25, self.width * 0.125 * 0.65)
  lg.circle("fill", self.width * 0.5, self.height * 0.75, self.width * 0.125 * 0.65)

  lg.rectangle("fill", self.width * 0.5 - self.width * 0.75 * 0.5, self.height * 0.5 - self.height * 0.125 * 0.5, self.width * 0.75, self.height * 0.125, 5, 5)

  lg.setCanvas()
end

function Obelus:draw (x, y, sx, sy)
  sx = Game:scaleWidth(sx)
  sy = Game:scaleWidth(sy)
  lg.draw(self.image, x - ((self.width * 0.5) * sx), y - ((self.height * 0.5) * sy), 0, sx, sy)
end
