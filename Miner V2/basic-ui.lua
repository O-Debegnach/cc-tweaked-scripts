local basalt = require("basalt")
local Miner = require("Miner")
local utils = require("utils")
local pretty = require("cc.pretty")

local configFile = "/miner_config.txt"

-- Leer configuración guardada
local function loadConfig()
    if not fs.exists(configFile) then
        return {}
    end
    local f = fs.open(configFile, "r")
    local data = {}
    while true do
        local line = f.readLine()
        if not line then
            break
        end
        local k, v = line:match("([^=]+)=([^=]+)")
        if k and v then
            if v == "true" then
                v = true
            elseif v == "false" then
                v = false
            elseif tonumber(v) then
                v = tonumber(v)
            end
            data[k] = v
        end
    end
    f.close()
    return data
end

-- Guardar configuración
local function saveConfig(cfg)
    local f = fs.open(configFile, "w")
    for k, v in pairs(cfg) do
        f.writeLine(k .. "=" .. tostring(v))
    end
    f.close()
end

local saved = loadConfig()

local main = basalt.createFrame()

local finishedFrame = basalt.createFrame():hide()

finishedFrame:addLabel():setText("✅ Excavación completada"):setPosition(5, 3)

finishedFrame:addButton():setText("Aceptar"):setPosition(6, 5):onClick(function()
    finishedFrame:hide()
    main:show()
end)


local errorFrame = basalt.createFrame():hide()

local errorLabel = errorFrame:addLabel():setText(""):setPosition(2, 3)

errorFrame:addButton():setText("Aceptar"):setPosition(6, 10):onClick(function()
    errorFrame:hide()
    main:show()
end)

local function showError(message)
    errorLabel:setText("❌ " .. message)
    main:hide()
    errorFrame:show()
end


-- Título
main:addLabel():setText("Configuración de Miner"):setPosition(2, 1)

-- Fill walls checkbox
local fillWallsCheckbox = main:addCheckbox():setText("Rellenar paredes (fillWalls)"):setPosition(2, 3):setValue(saved.fillWalls == true)

-- Dirección horizontal/vertical
main:addLabel():setText("Direccion:"):setPosition(2, 5)
local directionDropdown = main:addDropdown():setPosition(13, 5):addItem({
  text = "Horizontal", callback = function() showError('Horizontal') end
}):addItem({
  text = "Vertical", callback = function() showError('Vertical') end
}):setSize(10, 1)
utils.setDropdownValue(directionDropdown, saved.direction or "horizontal")

-- maxStepY
main:addLabel():setText("Paso vertical:"):setPosition(2, 7)
local stepYInput = main:addInput():setPosition(17, 7):setSize(5, 1):setInputType("number"):setValue(tostring(
    saved.maxStepY or ""))

-- Coordenadas X Y Z
main:addLabel():setText("X:"):setPosition(2, 9)
local xInput = main:addInput():setPosition(5, 9):setSize(5, 1):setInputType("number"):setValue(tostring(saved.x or ""))

main:addLabel():setText("Y:"):setPosition(12, 9)
local yInput = main:addInput():setPosition(15, 9):setSize(5, 1):setInputType("number"):setValue(tostring(saved.y or ""))

main:addLabel():setText("Z:"):setPosition(22, 9)
local zInput = main:addInput():setPosition(25, 9):setSize(5, 1):setInputType("number"):setValue(tostring(saved.z or ""))

-- Storage Position
main:addLabel():setText("Storage X:"):setPosition(2, 11)
local storageX = main:addInput():setPosition(13, 11):setSize(5, 1):setInputType("number"):setValue(tostring(
    saved.storageX or 0))

main:addLabel():setText("Storage Y:"):setPosition(2, 12)
local storageY = main:addInput():setPosition(13, 12):setSize(5, 1):setInputType("number"):setValue(tostring(
    saved.storageY or 0))

main:addLabel():setText("Storage Z:"):setPosition(2, 13)
local storageZ = main:addInput():setPosition(13, 13):setSize(5, 1):setInputType("number"):setValue(tostring(
    saved.storageZ or -3))


-- Botón de inicio
main:addButton():setText("Comenzar"):setPosition(25, 11):onClick(function()
    -- Leer valores
    local fillWalls = fillWallsCheckbox:getValue()
    
    local direction = utils.getDropdownValue(directionDropdown)
    if direction ~= "horizontal" and direction ~= "vertical" then
        showError("Dirección inválida. \nDebe ser 'horizontal' o 'vertical'.")
        showError("Direccion: " .. pretty.pretty(directionDropdown:getValue()))
        return
    end

    local stepY = tonumber(stepYInput:getValue()) or 1
    local x = tonumber(xInput:getValue()) or 0
    local y = tonumber(yInput:getValue()) or 0
    local z = tonumber(zInput:getValue()) or 0

    -- Validación básica
    if x == 0 or y == 0 or z == 0 then
        showError("Las dimensiones deben ser distintas a 0.")
        return
    end

    -- Guardar config
    local storagePos = {
        x = tonumber(storageX:getValue()) or 0,
        y = tonumber(storageY:getValue()) or 0,
        z = tonumber(storageZ:getValue()) or -3
    }

    -- Guardar config
    saveConfig({
        fillWalls = fillWalls,
        direction = direction,
        maxStepY = stepY,
        x = x,
        y = y,
        z = z,
        storageX = storagePos.x,
        storageY = storagePos.y,
        storageZ = storagePos.z
    })

    local miner = Miner:new({
        fillWalls = fillWalls,
        direction = direction,
        storagePosition = storagePos,
        maxStepY = stepY,
        debug = true
    })

    main:hide()
    miner:dig(x, y, z)
    finishedFrame:show()
end)

basalt.autoUpdate()
