-- Miner.lua optimizado para trabajar con TurtleController.lua
local TurtleController = require("TurtleController")
local utils = require("utils")

local Miner = {}
Miner.__index = Miner

function Miner:new(config)
    local self = setmetatable({}, Miner)
    self.turtle = TurtleController:new({
        breakBlocks = true
    })
    self.config = {
        fillWalls = config.fillWalls or false,
        direction = config.direction or "horizontal", -- "vertical" o "horizontal"
        storagePosition = config.storagePosition or nil,
        maxStepY = config.maxStepY or 3,
        debug = config.debug or false
    }
    return self
end

function Miner:log(...)
    if self.config.debug then
        print("[Miner]", ...)
    end
end

function Miner:isInventoryFull()
    for i = 1, 16 do
        if turtle.getItemCount(i) == 0 then
            return false
        end
    end
    return true
end

function Miner:findBlockSlot()
    for i = 1, 16 do
        local detail = turtle.getItemDetail(i)
        if detail and not string.find(detail.name, "fuel") then
            return i
        end
    end
    return nil
end

function Miner:placeWall(direction)
    local slot = self:findBlockSlot()
    if not slot then
        return false
    end
    local current = turtle.getSelectedSlot()
    turtle.select(slot)
    local ok = false
    if direction == "up" then
        ok = turtle.placeUp()
    elseif direction == "down" then
        ok = turtle.placeDown()
    elseif direction == "front" then
        ok = turtle.place()
    end
    turtle.select(current)
    return ok
end

function Miner:getWallDirections(pos, dim)
    local dirs = {}
    if pos.x == 0 then
        table.insert(dirs, 3)
    end
    if pos.x == dim.x - 1 then
        table.insert(dirs, 1)
    end
    if pos.z == 0 then
        table.insert(dirs, 2)
    end
    if pos.z == dim.z - 1 then
        table.insert(dirs, 0)
    end
    if pos.y == 0 then
        table.insert(dirs, "down")
    end
    if pos.y == dim.y - 1 then
        table.insert(dirs, "up")
    end
    return dirs
end

function Miner:fillWallsIfNeeded(pos, dim)
    if not self.config.fillWalls then
        return
    end
    local dirs = self:getWallDirections(pos, dim)
    local rot = self.turtle:getRotation()
    for _, dir in ipairs(dirs) do
        if dir == "up" then
            self:placeWall("up")
        elseif dir == "down" then
            self:placeWall("down")
        elseif type(dir) == "number" then
            self.turtle:setRotation(dir)
            self:placeWall("front")
        end
    end
    self.turtle:setRotation(rot)
end

function Miner:dumpInventory()
    if not self.config.storagePosition then
        return
    end
    self:log("Dumping inventory...")
    local sx, sy, sz = self.config.storagePosition.x, self.config.storagePosition.y, self.config.storagePosition.z
    local facing = (sz < 0) and 2 or 0
    self.turtle:moveTo(sx, sy, sz + ((sz < 0) and 1 or -1))
    self.turtle:setRotation(facing)
    for i = 1, 16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)
end

function Miner:dig(xSize, ySize, zSize)
    local dim = {
        x = math.abs(xSize) or 0,
        y = math.abs(ySize) or 0,
        z = math.abs(zSize) or 0
    }
    
    if dim.x == 0 or dim.y == 0 or dim.z == 0 then
        return false, "Invalid dimensions"
    end

    local xDir = (xSize >= 0) and 1 or -1
    local yDir = (ySize >= 0) and 1 or -1
    local zDir = (zSize >= 0) and 1 or -1
    self:log("Starting dig", dim.x, dim.y, dim.z)

    local function getVerticalStep(currY)
        local remaining = dim.y - currY - 1
        local step = math.min(self.config.maxStepY, remaining)
        return self.config.fillWalls and 1 or step
    end

    local function isAtYBorder()
        return self.turtle.currentPosition.y == 0 or self.turtle.currentPosition.y == dim.y
    end


    local function digCell()
        local pos = {
            x = self.turtle.currentPosition.x,
            y = self.turtle.currentPosition.y,
            z = self.turtle.currentPosition.z
        }
        self:fillWallsIfNeeded(pos, dim)
        if not self.config.fillWalls then
            local dirs = self:getWallDirections(pos, dim)
            if not utils.contains(dirs, "up") then
                self.turtle:digUp()
            end
            if not utils.contains(dirs, "down") then
                self.turtle:digDown()
            end
        end
    end

    if self.config.direction == "vertical" then
        for y = 0, dim.y - 1 do
            self:log("Excavating layer Y =", self.turtle.currentPosition.y)
            local zForward = (y % 2 == 0) and 1 or -1
            for z = 0, dim.z - 1 do
                local realZ = (zForward == 1) and z or (dim.z - 1 - z)
                if z > 0 then
                    self.turtle:move(0, 0, zForward)
                end
                for x = 0, dim.x - 1 do
                    if self:isInventoryFull() then
                        local cx, cy, cz = self.turtle:getCurrentPosition()
                        self:log("Inventory full, returning to dump")
                        self:dumpInventory()
                        self.turtle:moveTo(cx, cy, cz)
                    end
                    digCell()
                    if x < dim.x - 1 then
                        self.turtle:move(((z + y) % 2 == 0) and xDir or -xDir, 0, 0)
                    end
                end
            end
            if y < dim.y - 1 then
                local _, currY, _ = self.turtle:getCurrentPosition()
                local step = getVerticalStep(currY)
                if step > 0 then
                    self.turtle:move(0, step, 0)
                end
            end
        end
    else
        local initY = 1
        for z = 1, dim.z do
            self:log("Excavating layer Z =", self.turtle.currentPosition.z)
            local y = initY
            
            if(isAtYBorder() and math.abs(dim.y) > 2 and not self.config.fillWalls) then
                self.turtle:move(0, 1 * yDir, 0)
                y = y + 1
                initY = 2
            end

            while y <= dim.y do
                print("Excavating Y =" .. y .. " current Y =" .. self.turtle.currentPosition.y)
                for x = 1, dim.x do
                    if self:isInventoryFull() then
                        local cx, cy, cz = self.turtle:getCurrentPosition()
                        self:log("Inventory full, returning to dump")
                        self:dumpInventory()
                        self.turtle:moveTo(cx, cy, cz)
                    end
                    digCell()
                    if x + 1 <= dim.x then
                        self.turtle:move(xDir, 0, 0)
                    end
                end

                xDir = -xDir
                
                -- local _, currY, _ = self.turtle:getCurrentPosition()
                local step = getVerticalStep(y)
                print("y: " .. y .. " DimY:" .. dim.y .. " step:" .. step)
                y = y + step
                if step > 0 then
                    self.turtle:move(0, step * yDir, 0)
                else
                    break
                end
                
            end
            yDir = -yDir

            if z + 1 <= dim.z then
                self.turtle:move(0, 0, zDir)
            end
        end
    end

    self:dumpInventory()
    self.turtle:goToBase()
    self.turtle:setRotation(0)
    self:log("Excavation complete.")
end

return Miner
