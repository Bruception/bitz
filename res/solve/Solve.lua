require("Node")

local startNode = Node:new({
    {6, 6, 4},
    {5, 3},
    {5, 3},
    {6, 6, 4}
})

local goalNode = Node:new({
    {5, 3},
    {6, 6, 4},
    {6, 6, 4},
    {5, 3}
})

local currentQueue = {startNode}
local tempQueue = {}

local moves = 0

local found = false

local currentQueueLength = #currentQueue
local tempQueueLength = #tempQueue

local stash = {}

while(not found) do

  for i, node in ipairs(currentQueue) do -- for every node in the current queue

    if(node:compareSum(goalNode)) then -- If the current node is equal to the goal node
      found = true
      print(node.history)
      break
    else
      node:generateChildren()
      for n = 1, #node.children do
        tempQueue[#tempQueue + 1] = node.children[n]
      end
    end

    if(i == currentQueueLength) then -- Increment moves once we have iterated through the currentQueue
      moves = moves + 1
      print(moves)
    end
  end

  for i = currentQueueLength, 1, -1 do -- Clean currentQueue
    table.remove(currentQueue, i)
  end

  for i = tempQueueLength, 1, -1 do -- Clean tempQueue
    currentQueue[#currentQueue + 1] = tempQueue[i]
    table.remove(tempQueue, i)
  end

  currentQueueLength = #currentQueue
  tempQueueLength = #tempQueue

end

print("Min moves: " .. moves)
