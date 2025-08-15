local basalt = require("basalt")
local Miner = require("Miner")
local getFinishedFrame = require("ui.finishedFrame")


local main = basalt.getMainFrame()
  :initializeState('dimX', "", true)
  :initializeState('dimY', "", true)
  :initializeState('dimZ', "", true)
  :initializeState('direction', "horizontal", true)
  :initializeState('fillWalls', false, true)
  :initializeState('storX', "0", true)
  :initializeState('storY', "0", true)
  :initializeState('storZ', "-1", true)

local finishedFrame = getFinishedFrame(main)

-- local errorFrame = basalt.createFrame():hide()

-- local errorLabel = errorFrame:addLabel():setText(""):setPosition(2, 3)

-- errorFrame:addButton():setText("Aceptar"):setPosition(6, 10):onClick(function()
-- 	errorFrame:hide()
-- 	main:show()
-- end)

-- local function showError(message)
-- 	errorLabel:setText("❌ " .. message)
-- 	main:hide()
-- 	errorFrame:show()
-- end

main:addLabel()
  :setText("Dims:")
  :setPosition(2, 2)
main:addLabel()
  :setText("X:")
  :setPosition(2, 4)

main:addInput({
    width = 5,
    x = 4,
    y = 4,
    text = "1"
  })
  :bind("text", "dimX")

main:addLabel()
  :setText("Y:")
  :setPosition(2, 6)

main:addInput({
    width = 5,
    x = 4,
    y = 6,
    text = "1"
  })
  :bind("text", "dimY")

main:addLabel()
  :setText("Z:")
  :setPosition(2, 8)

main:addInput({
    width = 5,
    x = 4,
    y = 8,
    text = "1"
  })
  :bind("text", "dimZ")


main:addLabel()
  :setText("Modo:")
  :setPosition(15, 2)
main:addDropdown({
    width = 15,
    x = 20,
    y = 2,
  })
  :addItem({
    text = "horizontal",
    callback = function() main:setState("direction", "horizontal") end
  })
  :addItem({
    text = "vertical",
    callback = function() main:setState("direction", "vertical") end
  }): bind("selectedText", "direction")


main:addLabel()
  :setText("Rellenar paredes?")
  :setPosition(15, 4)
main:addCheckbox({
    x = 33,
    y = 4,
    text = "No",
	checkedText = "Si",
  }):bind("checked", "fillWalls")
  


main:addLabel()
  :setText("Pos Almacenamiento:")
  :setPosition(15, 6)
main:addLabel()
  :setText("X:")
  :setPosition(15, 8)
main:addInput({
    width = 5,
    x = 18,
    y = 8,
    text = "0"
  })
  :bind("text", "storX")

main:addLabel()
  :setText("Y:")
  :setPosition(15, 10)
main:addInput({
    width = 5,
    x = 18,
    y = 10,
    text = "0"
  })
  :bind("text", "storY")

main:addLabel()
  :setText("Z:")
  :setPosition(15, 12)
main:addInput({
    width = 5,
    x = 18,
    y = 12,
    text = "-1"
  })
  :bind("text", "storZ")

  
main:addButton()
  :setText("Iniciar Excavación")
  :setPosition(2, 10)
  :onClick(function()
    local config = {
      fillWalls = main:getState("fillWalls"),
	  direction = main:getState("direction"),
	  maxStepY = 3,
	  x = tonumber(main:getState("storX")) or 0,
	  y = tonumber(main:getState("storY")) or 0,
	  z = tonumber(main:getState("storZ")) or -1
    }

    local miner = Miner:new(config)

    local dimX = tonumber(main:getState("dimX"))
    local dimY = tonumber(main:getState("dimY"))
    local dimZ = tonumber(main:getState("dimZ"))

    miner:dig(dimX, dimY, dimZ)
	basalt.setActiveFrame(finishedFrame)
    print("Miner initialized with config:", config)  
  end)


basalt.run()