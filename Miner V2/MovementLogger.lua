local MovementLogger = {}
MovementLogger.__index = MovementLogger

function MovementLogger:new(filename)
    local self = setmetatable({}, MovementLogger)
    self.filename = filename or "movement_log.txt"
    self.totalMoves = 0
    self.fuelUsed = 0
    self:writeHeader()
    return self
end

function MovementLogger:writeHeader()
    local file = io.open(self.filename, "w")
    if file then
        file:write("=== TURTLE MOVEMENT LOG ===\n")
        file:write("Time: " .. os.date() .. "\n")
        file:write("Format: [Move#] Direction: Amount (Total Fuel Used)\n")
        file:write("================================\n\n")
        file:close()
    end
end

function MovementLogger:logMovement(direction, amount)
    if amount == 0 then return end
    
    self.totalMoves = self.totalMoves + 1
    self.fuelUsed = self.fuelUsed + math.abs(amount)
    
    local directionStr = ""
    if direction == "x" then
        directionStr = amount > 0 and "+X" or "-X"
    elseif direction == "y" then
        directionStr = amount > 0 and "+Y" or "-Y"
    elseif direction == "z" then
        directionStr = amount > 0 and "+Z" or "-Z"
    end
    
    local file = io.open(self.filename, "a")
    if file then
        file:write(string.format("[%d] %s: %d (Fuel: %d)\n", 
            self.totalMoves, directionStr, math.abs(amount), self.fuelUsed))
        file:close()
    end
end

function MovementLogger:logPosition(x, y, z)
    local file = io.open(self.filename, "a")
    if file then
        file:write(string.format("Position: (%d, %d, %d)\n", x, y, z))
        file:close()
    end
end

function MovementLogger:logSummary()
    local file = io.open(self.filename, "a")
    if file then
        file:write("\n=== MOVEMENT SUMMARY ===\n")
        file:write("Total movements: " .. self.totalMoves .. "\n")
        file:write("Total fuel used: " .. self.fuelUsed .. "\n")
        file:write("========================\n")
        file:close()
    end
end

return MovementLogger
