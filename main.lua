local Miner = require("Miner")

local miner = Miner:new()

-- Prueba de la función digCube con dimensiones 3x3x3
local success, message = miner:digCube(3, 3, 3)

if success then
  print("Excavación completada con éxito.")
else
  print("Error en la excavación: " .. message)
end
