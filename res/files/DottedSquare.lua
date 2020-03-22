
local lg = love.graphics

DottedSquare = {}

local WIDTH_KEYS = {
  [0] = 2.5,
  [3] = 3,
  [4] = 4,
  [5] = 5,
  [6] = 6
}

function DottedSquare:load()
  self.x = 0
  self.y = 0

  self.width = 50
  self.height = Game:scaleHeight(180 * 0.85) * 0.22

  self.linesX = 10
  self.linesY = 10

  self.outlines = {}

  self.stencilFunc = function()
    lg.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
    lg.rectangle("line", self.x, self.y, self.width, self.height, 5, 5)
  end

  for k, v in pairs(WIDTH_KEYS) do
    self.width = Game:scaleWidth((WIDTH_KEYS[k] * 20) * 0.85)
    self.outlines[k] = lg.newCanvas(self.width, self.height)

    lg.setCanvas{self.outlines[k], stencil = true}
    lg.stencil(self.stencilFunc, "replace", 1, false)

    lg.setStencilTest("equal", 1)


    lg.setLineWidth(3)

    lg.setColor(1, 1, 1, 1)

    for i = self.x + 5, self.x + self.width - 5, self.linesY do
      lg.line(i, self.y, i, self.height)
    end
    for i = self.y + 5, self.y + self.height, self.linesX do
      lg.line(self.x, i, self.width, i)
    end

    lg.setStencilTest()
    lg.setCanvas()
  end
end

function DottedSquare:draw(weight, x, y, w, h)

  lg.draw(self.outlines[weight], x, y)

end
