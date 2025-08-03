local TurtleController = require("TurtleController")

local Miner = {}
Miner.__index = Miner

function Miner:new(config)
    local self = setmetatable({}, Miner)
    self.turtleController = TurtleController:new()
    self.turtleController:setMovementConfig({
        breakBlocks = true
    })

    self.storagePosition = config.storagePosition or nil
    self.fillWalls = config.fillWalls or false
    self.direction = config.direction or "horizontal" -- "horizontal" o "vertical"
    self.maxStepY = config.maxStepY or 3
    self.keepRotation = config.keepRotation ~= false
    return self
end

function Miner:setStoragePosition(x, y, z)
    self.storagePosition = {
        x = x,
        y = y,
        z = z
    }
end

function Miner:checkInventoryFull()
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    return true
end

function Miner:findBlockInInventory()
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            local detail = turtle.getItemDetail(i)
            if detail and detail.name and not string.find(detail.name, "fuel") then
                return i
            end
        end
    end
    return nil
end

function Miner:placeBlock(direction)
    if not self.fillWalls then
        return false
    end

    local slot = self:findBlockInInventory()
    if not slot then
        return false
    end

    local currentSlot = turtle.getSelectedSlot()
    turtle.select(slot)

    local success = false
    if direction == "up" then
        success = turtle.placeUp()
    elseif direction == "down" then
        success = turtle.placeDown()
    elseif direction == "front" then
        success = turtle.place()
    end

    turtle.select(currentSlot)
    return success
end

function Miner:getBorderDirections(dim)
    local x, y, z = self.turtleController:getCurrentPosition()
    local dirs = {}

    if x == 0 then
        table.insert(dirs, 3)
    end -- izquierda
    if x == dim.x - 1 then
        table.insert(dirs, 1)
    end -- derecha
    if z == 0 then
        table.insert(dirs, 2)
    end -- atrás
    if z == dim.z - 1 then
        table.insert(dirs, 0)
    end -- frente
    if y == 0 then
        table.insert(dirs, "down")
    end
    if y == dim.y - 1 then
        table.insert(dirs, "up")
    end

    return dirs
end

function Miner:fillBorderIfNeeded(dim)
    if not self.fillWalls then
        return
    end
    local dirs = self:getBorderDirections(dim)
    local currentRot = self.turtleController:getRotation()

    for _, d in ipairs(dirs) do
        if d == "up" then
            self:placeBlock("up")
        elseif d == "down" then
            self:placeBlock("down")
        elseif type(d) == "number" then
            self.turtleController:setRotation(d)
            self:placeBlock("front")
        end
    end

    if self.keepRotation then
        self.turtleController:setRotation(currentRot)
    end
end

function Miner:dumpInventory()
    if not self.storagePosition then
        return
    end

    local sx, sy, sz = self.storagePosition.x, self.storagePosition.y, self.storagePosition.z
    local dirZ = (sz < 0) and 2 or 0

    self.turtleController:moveTo(sx, sy, sz + ((sz < 0) and 1 or -1))
    self.turtleController:setRotation(dirZ)

    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end

    turtle.select(1)
end

function Miner:digCube(xSize, ySize, zSize)
    local dim = {
        x = math.abs(xSize),
        y = math.abs(ySize),
        z = math.abs(zSize)
    }

    if dim.x == 0 or dim.y == 0 or dim.z == 0 then
        return false, "Dimensiones inválidas"
    end

    local xDir = xSize > 0 and 1 or -1
    local yDir = ySize > 0 and 1 or -1
    local zDir = zSize > 0 and 1 or -1

    local function digCell(dim)
        self:fillBorderIfNeeded(dim)

        if not self.fillWalls then
            while turtle.detectUp() do
                turtle.digUp()
            end
            while turtle.detectDown() do
                turtle.digDown()
            end
        end
    end

    if self.direction == "vertical" then
        for x = 0, dim.x - 1 do
            for z = 0, dim.z - 1 do
                for y = 0, dim.y - 1 do
                    digCell(dim)
                    if y < dim.y - 1 then
                        self.turtleController:move(0, 1 * yDir, 0)
                    end
                end
                if z < dim.z - 1 then
                    self.turtleController:move(0, -yDir * (dim.y - 1), 1 * zDir)
                end
            end
            if x < dim.x - 1 then
                self.turtleController:move(1 * xDir, 0, -zDir * (dim.z - 1))
            end
        end
    else -- horizontal por capas
        for z = 0, dim.z - 1 do
            for y = 0, dim.y - 1 do
                for x = 0, dim.x - 1 do
                    if self:checkInventoryFull() then
                        local cx, cy, cz = self.turtleController:getCurrentPosition()
                        self:dumpInventory()
                        self.turtleController:moveTo(cx, cy, cz)
                    end
                    digCell(dim)
                    if x < dim.x - 1 then
                        self.turtleController:move(1 * xDir, 0, 0)
                    end
                end
                xDir = -xDir
                if y < dim.y - 1 then
                    local stepY = self.fillWalls and 1 or math.min(self.maxStepY, dim.y - y - 1)
                    self.turtleController:move(0, stepY * yDir, 0)
                end
            end
            if z < dim.z - 1 then
                self.turtleController:move(0, -yDir * (dim.y - 1), 1 * zDir)
            end
        end
    end

    self:dumpInventory()
    self.turtleController:goToBase()
    self.turtleController:setRotation(0)
    return true
end

return Miner
