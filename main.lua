
math.randomseed(os.time());math.random();math.random();math.random();

IOS = (love.system.getOS() == "iOS")

left, top, right, bottom = 0, 0, 0, 0


-- bitzleaderboard
-- bitztestleaderboard2

LEADERBOARD_ID = "bitzleaderboard" --- CHANGE THIS FOR RELEASE

if IOS then
  left, top, right, bottom = love.window.getSafeAreaInsets()
  love.system.authenticateLocalPlayer()
end

function love.load()
  Loader = require("Loader")
  Loader:load()

  Game:load()
end

function love.update(dt)
  Game:update(dt)
end

function love.draw()
  Game:draw()
end

function love.touchreleased(id, x, y)
  Game:touchReleased(id, x, y)
end

function love.touchmoved(id, x, y, dx, dy)
  Game:touchMoved(id, x, y, dx, dy)
end
