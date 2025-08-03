-- Buscar monitor conectado por wired modem
local monitor = peripheral.find("monitor")
if not monitor then
    print("No se encontró ningún monitor conectado.")
    return
end

-- CONFIGURACIÓN GENERAL
local bgColor = colors.lime
local textColor = colors.black
local delay = 0.03 -- velocidad de animación

-- 🖥️ CONFIGURACIÓN DEL ÁREA DE TEXTO
local totalWidth, totalHeight = monitor.getSize()
local marginX, marginY = 2, 2
local usableWidth = totalWidth - marginX * 2
local usableHeight = totalHeight - marginY * 2


-- TEXTO A MOSTRAR
local text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, urna eu tincidunt consectetur, nisi nisl aliquam enim, eget consequat sapien urna nec urna. Proin ac massa nec sapien dictum tincidunt. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Suspendisse potenti. Mauris euismod, justo at facilisis cursus, enim erat dictum urna, nec dictum erat erat eu erat. Etiam euismod, urna eu tincidunt consectetur, nisi nisl aliquam enim, eget consequat sapien urna nec urna. Proin ac massa nec sapien dictum tincidunt. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Suspendisse potenti. Mauris euismod, justo at facilisis cursus, enim erat dictum urna, nec dictum erat erat eu erat."

-- Inicializar monitor
monitor.setBackgroundColor(bgColor)
monitor.setTextColor(textColor)
monitor.setCursorBlink(false)
monitor.clear()

-- Función para ajustar texto por palabra (word wrap)
local function wrapText(text, maxWidth)
    local lines = {}
    local line = ""
    for word in text:gmatch("%S+") do
        if #line + #word + 1 <= maxWidth then
            if line == "" then
                line = word
            else
                line = line .. " " .. word
            end
        else
            table.insert(lines, line)
            line = word
        end
    end
    if line ~= "" then
        table.insert(lines, line)
    end
    return lines
end

-- Función para escribir animadamente
local function typeWriter(term, lines, startX, startY)
    for i, line in ipairs(lines) do
        if i > usableHeight then break end
        term.setCursorPos(startX, startY + i - 1)
        for c = 1, #line do
            term.write(line:sub(c, c))
            sleep(delay)
        end
    end
end

-- Función para borrar animadamente
local function eraseWriter(term, lines, startX, startY)
    for i = #lines, 1, -1 do
        if i > usableHeight then break end
        local line = lines[i]
        for j = #line, 1, -1 do
            term.setCursorPos(startX + j - 1, startY + i - 1)
            term.write(" ")
            sleep(delay)
        end
    end
end

-- Obtener líneas ajustadas
local wrappedLines = wrapText(text, usableWidth)

-- Bucle infinito
while true do
    monitor.clear()
    typeWriter(monitor, wrappedLines, marginX, marginY)
    sleep(1)
    eraseWriter(monitor, wrappedLines, marginX, marginY)
    sleep(0.5)
end
