local Miner = require("Miner")

-- Solicitar dimensiones al usuario
print("Ingrese ancho (X):")
local x = tonumber(read())
print("Ingrese alto (Y):")
local y = tonumber(read())
print("Ingrese profundidad (Z):")
local z = tonumber(read())

-- Instanciar minero con configuración
local miner = Miner:new({
    fillWalls = true,
    direction = "horizontal", -- también podés usar "vertical"
    storagePosition = {
        x = 0,
        y = 0,
        z = -3
    },
    maxStepY = 2,
    debug = true
})

miner:dig(x, y, z)
