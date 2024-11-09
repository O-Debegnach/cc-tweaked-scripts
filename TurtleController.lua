-- TurtleController.lua
-- Purpose: This class is used to control the turtle. It is used to move the turtle in the world.
TurtleController = {}
TurtleController.__index = TurtleController

function TurtleController:new()
    local self = setmetatable({}, TurtleController)
    self.rotation = 0
    self.initialPosition = {
        x = 0,
        y = 0,
        z = 0
    }
    self.currentPosition = {
        x = 0,
        y = 0,
        z = 0
    }
    self.movementConfig = {
        breakBlocks = false,
        autoRefuel = true,
        refuelThreshold = 100
    }
    return self
end

function TurtleController:initPosition()
    self.initialPosition = {
        x = 0,
        y = 0,
        z = 0
    }
    self.currentPosition = {
        x = 0,
        y = 0,
        z = 0
    }
end

function TurtleController:refuel()
    if turtle.getFuelLevel() == "unlimited" then
        return true
    end

    if turtle.getFuelLevel() < self.movementConfig.refuelThreshold then
        for i = 1, 16 do
            turtle.select(i)
            if turtle.refuel(0) then
                turtle.refuel()
                if turtle.getFuelLevel() >= self.movementConfig.refuelThreshold then
                    return true
                end
            end
        end
    end
    return true
end

function TurtleController:forward()
    self:refuel()

    if turtle.forward() then
        if self.rotation == 0 then
            self.currentPosition.z = self.currentPosition.z + 1
        elseif self.rotation == 1 then
            self.currentPosition.x = self.currentPosition.x + 1
        elseif self.rotation == 2 then
            self.currentPosition.z = self.currentPosition.z - 1
        elseif self.rotation == 3 then
            self.currentPosition.x = self.currentPosition.x - 1
        end
        return true
    else
        return false
    end
end

function TurtleController:back()
    self:refuel()

    if turtle.back() then
        if self.rotation == 0 then
            self.currentPosition.z = self.currentPosition.z - 1
        elseif self.rotation == 1 then
            self.currentPosition.x = self.currentPosition.x - 1
        elseif self.rotation == 2 then
            self.currentPosition.z = self.currentPosition.z + 1
        elseif self.rotation == 3 then
            self.currentPosition.x = self.currentPosition.x + 1
        end
        return true
    else
        return false
    end
end

function TurtleController:up()
    self:refuel()

    if turtle.up() then
        self.currentPosition.y = self.currentPosition.y + 1
        return true
    else
        return false
    end
end

function TurtleController:down()
    self:refuel()

    if turtle.down() then
        self.currentPosition.y = self.currentPosition.y - 1
        return true
    else
        return false
    end
end

function TurtleController:turnLeft()
    turtle.turnLeft()
    self.rotation = (self.rotation - 1) % 4
end

function TurtleController:turnRight()
    turtle.turnRight()
    self.rotation = (self.rotation + 1) % 4
end

function TurtleController:turnAround()
    turtle.turnLeft()
    turtle.turnLeft()
    self.rotation = (self.rotation + 2) % 4
end

function TurtleController:restoreRotation()
    while self.rotation ~= 0 do
        turtle.turnRight()
        self.rotation = (self.rotation + 1) % 4
    end
end

function TurtleController:setRotation(rotation)
    while self.rotation ~= rotation do
        turtle.turnRight()
        self.rotation = (self.rotation + 1) % 4
    end
end

function TurtleController:setMovementConfig(config)
    for key, value in pairs(config) do
        self.movementConfig[key] = value
    end
end

function TurtleController:move(x, y, z)
    if (y ~= 0) then
        for i = 1, math.abs(y) do
            if (y > 0) then
                if (self.movementConfig.breakBlocks) then
                    while turtle.detectUp() do
                        turtle.digUp()
                    end
                end
                if not self:up() then
                    return false
                end
            else
                if (self.movementConfig.breakBlocks) then
                    while turtle.detectDown() do
                        turtle.digDown()
                    end
                end
                if not self:down() then
                    return false
                end
            end
        end
    end

    if (x ~= 0) then
        local rotation = x > 0 and 1 or 3
        self:setRotation(rotation)
        for i = 1, math.abs(x) do
            if (self.movementConfig.breakBlocks) then
                while turtle.detect() do
                    turtle.dig()
                end
            end
            if not self:forward() then
                return false
            end
        end
    end

    if (z ~= 0) then
        local rotation = z < 0 and 2 or 0
        self:setRotation(rotation)
        for i = 1, math.abs(z) do
            if (self.movementConfig.breakBlocks) then
                while turtle.detect() do
                    turtle.dig()
                end
            end
            if not self:forward() then
                return false
            end
        end
    end

    return true
end

function TurtleController:moveTo(x, y, z)
    local xDirection = x - self.currentPosition.x
    local yDirection = y - self.currentPosition.y
    local zDirection = z - self.currentPosition.z

    print("destination: x=" .. x .. ", y=" .. y .. ", z=" .. z)
    print(
        "current position: x=" ..
            self.currentPosition.x .. ", y=" .. self.currentPosition.y .. ", z=" .. self.currentPosition.z
    )
    print("directions: x=" .. xDirection .. ", y=" .. yDirection .. ", z=" .. zDirection)

    return self:move(xDirection, yDirection, zDirection)
end

function TurtleController:goToBase()
    self:moveTo(self.initialPosition.x, self.initialPosition.y, self.initialPosition.z)
end

function TurtleController:getCurrentPosition()
    return self.currentPosition.x, self.currentPosition.y, self.currentPosition.z
end

return TurtleController
