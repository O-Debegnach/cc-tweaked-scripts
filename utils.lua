local TurtleUtils = {}

function log(message, enabled)
    local enabled = enabled or false
    if not enabled then
        return
    end
    print(message)
end


function TurtleUtils.refuelIfNeeded()
    if turtle.getFuelLevel() < 10 then
        log("Nivel de combustible bajo, repostando...")
        turtle.refuel()
    end
end

function TurtleUtils.turnAround()
    TurtleUtils.refuelIfNeeded()
    log("Girando alrededor")
    turtle.turnLeft()
    turtle.turnLeft()
end

function TurtleUtils.move(direction)
    local directions = {
        forward = direction.forward or 0,
        back = direction.back or 0,
        left = direction.left or 0,
        right = direction.right or 0,
        up = direction.up or 0,
        down = direction.down or 0
    }

    if (directions.forward > 0) then
        for i = 1, directions.forward do
            TurtleUtils.refuelIfNeeded()
            log("Moviendo hacia adelante")
            while true do
                local success, reason = turtle.forward()
                if success then
                    break
                end
                log("Fallo al mover adelante: " .. reason)
                log("Rompiendo bloque adelante")
                turtle.dig()
            end
        end
    end

    if (directions.back > 0) then
        TurtleUtils.turnAround()
        for i = 1, directions.back do
            TurtleUtils.refuelIfNeeded()
            log("Moviendo hacia atrás")
            while true do
                local success, reason = turtle.forward()
                if success then
                    break
                end
                log("Fallo al mover atrás: " .. reason)
                log("Rompiendo bloque atrás")
                turtle.dig()
            end
        end
        TurtleUtils.turnAround()
    end

    if (directions.left > 0) then
        log("Girando a la izquierda")
        turtle.turnLeft()
        for i = 1, directions.left do
            TurtleUtils.refuelIfNeeded()
            log("Moviendo hacia la izquierda")
            while true do
                local success, reason = turtle.forward()
                if success then
                    break
                end
                log("Fallo al mover a la izquierda: " .. reason)
                log("Rompiendo bloque a la izquierda")
                turtle.dig()
            end
        end
        log("Girando a la derecha")
        turtle.turnRight()
    end

    if (directions.right > 0) then
        log("Girando a la derecha")
        turtle.turnRight()
        for i = 1, directions.right do
            TurtleUtils.refuelIfNeeded()
            log("Moviendo hacia la derecha")
            while true do
                local success, reason = turtle.forward()
                if success then
                    break
                end
                log("Fallo al mover a la derecha: " .. reason)
                log("Rompiendo bloque a la derecha")
                turtle.dig()
            end
        end
        log("Girando a la izquierda")
        turtle.turnLeft()
    end

    if (directions.up > 0) then
        for i = 1, directions.up do
            TurtleUtils.refuelIfNeeded()
            log("Moviendo hacia arriba")
            while true do
                local success, reason = turtle.up()
                if success then
                    break
                end
                log("Fallo al mover arriba: " .. reason)
                log("Rompiendo bloque arriba")
                turtle.digUp()
            end
        end
    end

    if (directions.down > 0) then
        for i = 1, directions.down do
            TurtleUtils.refuelIfNeeded()
            log("Moviendo hacia abajo")
            while true do
                local success, reason = turtle.down()
                if success then
                    break
                end
                log("Fallo al mover abajo: " .. reason)
                log("Rompiendo bloque abajo")
                turtle.digDown()
            end
        end
    end
end

function TurtleUtils.digCape(dimentions, inverted)
    for x = 1, dimentions.x do
        TurtleUtils.move({
            forward = dimentions.z - 1
        })
        if (x + 1 <= dimentions.x) then
            local odd = x % 2 == 0
            if (odd == inverted) then
                -- log("Girando a la derecha")
                turtle.turnRight()
                TurtleUtils.move({
                    forward = 1
                })
                -- log("Girando a la derecha")
                turtle.turnRight()
            else
                -- log("Girando a la izquierda")
                turtle.turnLeft()
                TurtleUtils.move({
                    forward = 1
                })
                -- log("Girando a la izquierda")
                turtle.turnLeft()
            end
        end
    end
end

function TurtleUtils.digCube(directions)
    local directions = {
        forward = directions.forward or 0,
        back = directions.back or 0,
        left = directions.left or 0,
        right = directions.right or 0,
        up = directions.up or 0,
        down = directions.down or 0
    }
    local dimentions = {
        x = directions.left + directions.right + 1,
        y = directions.up + directions.down + 1,
        z = directions.forward + directions.back + 1
    }

    TurtleUtils.move({
        left = directions.left,
        up = directions.up,
        back = directions.back
    })

    for y = 1, dimentions.y do
        local inverted = dimentions.x % 2 == 0 and y % 2 ~= 0
        log("Inverted: " .. tostring(inverted), enabled)
        log("Y: " .. y, enabled)
        log("Y impar: " .. tostring(y % 2 ~= 0), enabled)
        log("X par: " .. tostring(dimentions.x % 2 == 0), enabled)
        TurtleUtils.digCape(dimentions, inverted)

        if (y + 1 <= dimentions.y) then
            TurtleUtils.move({
                down = 1
            })
            TurtleUtils.turnAround()
        end
    end
end

return TurtleUtils
