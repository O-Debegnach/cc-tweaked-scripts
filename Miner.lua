local TurtleController = require("TurtleController")

Miner = {}
Miner.__index = Miner

function Miner:new()
  local self = setmetatable({}, Miner)
  self.turtleController = TurtleController:new()
  self.turtleController:setMovementConfig({breakBlocks = true})

  self.storagePosition = nil
  
  self.fillWalls = false
  return self
end

function Miner:setStoragePosition(x, y, z)
  self.storagePosition = {
    x = x or 0,
    y = y or 0,
    z = z or 0
  }
end

function Miner:dumpInventory()
  self.turtleController:moveTo(
    self.storagePosition.x,
    self.storagePosition.y,
    self.storagePosition.z + (self.storagePosition.z < 0 and 1 or -1)
  )
  self.turtleController:setRotation(self.storagePosition.z < 0 and 2 or 0)
  for i = 1, 16 do
    turtle.select(i)
    turtle.drop()
  end
  turtle.select(1)
end

function Miner:checkInventoryFull()
  for i = 1, 16 do
    if turtle.getItemCount(i) == 0 then
      return false
    end
  end
  return true
end

function Miner:digCube(x, y, z)
  local dimentions = {
    x = math.abs(x) or 0,
    y = math.abs(y) or 0,
    z = math.abs(z) or 0
  }

  local function isAtBorder()
    return self.turtleController.currentPosition.y == 0 or self.turtleController.currentPosition.y == dimentions.y
  end

  if (dimentions.x == 0 or dimentions.y == 0 or dimentions.z == 0) then
    return false, "Invalid dimentions"
  end

  local xDirection = x > 0 and 1 or -1
  local yDirection = y > 0 and 1 or -1
  local zDirection = z > 0 and 1 or -1
  local initY = 1
  for z = 1, dimentions.z do
    local y = initY
    if (isAtBorder() and math.abs(dimentions.y) > 2) then
      self.turtleController:move(0, 1 * yDirection, 0)
      y = y + 1
      initY = 2
    end
    while y <= dimentions.y do
      for x = 1, dimentions.x do
        if (self:checkInventoryFull()) then
          local currX, currY, currZ = self.turtleController:getCurrentPosition()
          print("Inventory full, returning to base")
          print("Current position: x=" .. currX .. ", y=" .. currY .. ", z=" .. currZ)
          self:dumpInventory()
          self.turtleController:moveTo(currX, currY, currZ)
        end

        if (y + 1 <= dimentions.y) then
          while turtle.detectUp() do
            turtle.digUp()
          end
        end

        if (y - 1 > 0) then
          while turtle.detectDown() do
            turtle.digDown()
          end
        end
        if (x + 1 <= dimentions.x) then
          self.turtleController:move(xDirection, 0, 0)
        end
      end
      xDirection = xDirection == 1 and -1 or 1
      local deltaY = math.min(dimentions.y - y - 1, 3)
      y = y + deltaY
      if (deltaY > 0) then
        self.turtleController:move(0, deltaY * yDirection, 0)
      else
        break
      end
    end
    yDirection = yDirection == 1 and -1 or 1
    if (z + 1 <= dimentions.z) then
      self.turtleController:move(0, 0, zDirection)
    end
  end

  if(self.storagePosition) then
    self:dumpInventory()
  end
  self.turtleController:goToBase()
  self.turtleController:setRotation(0);
  return true
end

return Miner
