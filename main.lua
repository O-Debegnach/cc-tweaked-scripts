local Miner = require("Miner")

local miner = Miner:new()

-- Prueba de la función digCube con dimensiones 3x3x3
miner:setStoragePosition(0, 0, -1)
miner.turtleController:setMovementConfig({breakBlocks = true})
local success, message = miner:digCube(4, 6, 12)

if success then
  print("Excavación completada con éxito.")
else
  print("Error en la excavación: " .. message)
end
