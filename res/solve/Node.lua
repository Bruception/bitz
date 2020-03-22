
local stash = {}

local function table_reduce(list, fn)
    local acc
    for k, v in ipairs(list) do
        if 1 == k then
            acc = v
        else
            acc = fn(acc, v)
        end
    end
    return acc
end

local function getHash(map)
  local hash = ""

  for i = 1, 4 do
    for j = 1, #map[i] do

      if(map[i][j] == nil) then
        hash = hash .. "n"
      else
        hash = hash .. map[i][j]
      end
    end
    hash = hash .. ":"
  end

  return hash
end

local function getFirstPieceFromStack(map, stack)
  return map[stack][#map[stack]]
end

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

Node = {}

Node.__index = Node

function Node:new(map, history)

  local self = {}

  self.map = map

  self.sums = {0, 0, 0, 0}

  for i = 1, 4 do
    self.sums[i] = table_reduce(
      self.map[i],

      function (a, b)
        return a + b
      end
    )
  end

  self.children = {}

  self.getHistoryBuffer = function(self)
    local history = ""
    for i = 1, 4 do
      if(self.sums[i] ~= nil) then
        history = history .. self.sums[i] .. ":"
      else
        history = history .. "n:"
      end
    end

    return history
  end

  local hB = self:getHistoryBuffer()

  local h = history or hB .. "\n"

  self.history = (h .. hB .. "\n") or (hB .. "\n")

  return setmetatable(self, Node)
end

function Node:generateChildren()
  local permutations = {}

  local piece

  for j = 1, 4 do

    piece = getFirstPieceFromStack(self.map, j)

    for i = 1, 4 do
      if(i ~= j and piece ~= nil) then
        local mapCopy = deepcopy(self.map)
        local length = #mapCopy[i]
        if((mapCopy[i][length] == nil or (mapCopy[i][length] >= piece)) and length < 4) then

          table.remove(mapCopy[j], #mapCopy[j])
          table.insert(mapCopy[i], piece)

          local hash = getHash(mapCopy)

          if(stash[hash] == nil) then
            permutations[#permutations + 1] = mapCopy
            stash[hash] = true
          end
        end
      end
    end

  end

  for i = 1, #permutations do
    self.children[#self.children + 1] = Node:new(permutations[i], self.history)
  end
end

function Node:compareSum(node)
  for i = 1, 4 do
    if(self.sums[i] ~= node.sums[i]) then
      return false
    end
  end

  return true
end
