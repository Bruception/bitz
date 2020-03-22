

Tester = {}

function Tester:load()

  self.content = Content:new({
    x = 0,
    y = 0,
    width = Game.WIDTH,
    height = 2300
  })

  for x = 35, 300, 50 do
    for y = 0, 2250, 50 do
      if(y % 100 == 0) then
        local b = Button:new({
          color = Game.colorPal1:getColor("blue"),
          colorHover = Game.colorPal2:getColor("blue"),
          width = 50,
          height = 50,
          x = x,
          y = y,
        })
        self.content:addObject(b, x, y)
      end
    end
  end

  self.scroll = Scroll:new({
    x = 0,
    y = 0,
    width = Game.WIDTH,
    height = Game.HEIGHT * 0.5,
    content = self.content,
    scrollColor = {0, 0, 0, 0.4}
  })

  self.content.scroll = self.scroll

  self.page1 = Page:new({
    x = 0,
    y = 0,
    index = 1,
    width = Game.WIDTH,
    height = Game.HEIGHT * 0.5,
  })

  self.page1:addObject(self.scroll, 0, 0)

  self.page2 = Page:new({
    x = 0,
    y = 0,
    index = 2,
    width = Game.WIDTH,
    height = Game.HEIGHT * 0.5,
  })

  self.page3 = Page:new({
    x = 0,
    y = 0,
    index = 3,
    width = Game.WIDTH,
    height = Game.HEIGHT * 0.5,
  })

  self.page4 = Page:new({
    x = 0,
    y = 0,
    index = 3,
    width = Game.WIDTH,
    height = Game.HEIGHT * 0.5,
  })

  self.page5 =  Page:new({
    x = 0,
    y = 0,
    index = 3,
    width = Game.WIDTH,
    height = Game.HEIGHT * 0.5,
  })

  self.pageScroller = PageScroll:new({
    width = Game.WIDTH,
    height = Game.HEIGHT * 0.5,
    x = 0,
    y = Game.HEIGHT * 0.25,
    pages = {
      self.page1,
      self.page2,
      self.page3,
      self.page4,
      self.page5
    }
  })
end

function Tester:update(dt)
  self.pageScroller:update(dt)
end

function Tester:draw()
  self.pageScroller:draw()
end

function Tester:touchReleased(id)
  self.pageScroller:touchReleased(id)
end

function Tester:touchMoved(id, x, y, dx, dy)
  self.pageScroller:touchMoved(id, x, y, dx, dy)
end
