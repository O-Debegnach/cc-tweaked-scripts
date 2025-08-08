local basalt = require("basalt")

local function getFinishedFrame(main)
  local finishedFrame = basalt.createFrame()

  finishedFrame:addLabel():setText("Excavacion completada"):setPosition(5, 3)

  finishedFrame:addButton():setText("Aceptar"):setPosition(6, 5):onClick(function()
    basalt.setActiveFrame(main)
  end)

  return finishedFrame
end

local function getErrorFrame(main)
  local errorFrame = basalt.createFrame():hide()

  local errorLabel = errorFrame:addLabel():setText(""):setPosition(2, 3)

  errorFrame:addButton():setText("Aceptar"):setPosition(6, 10):onClick(function()
    basalt.setActiveFrame(main)
  end)

  return {
    frame = errorFrame,
    label = errorLabel
  }
end
return getFinishedFrame, getErrorFrame
