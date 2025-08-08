local utils = {}

function utils.contains(t, value)
    for _, v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

function utils.getDropdownValue(dropdown)
    if dropdown and dropdown.getItem and dropdown.getSelectedIndex then
        local index = dropdown:getSelectedIndex()
        if index and index > 0 then
            return dropdown:getItem(index)
        end
    end
    return nil
end

function utils.setDropdownValue(dropdown, value)
    if dropdown and dropdown.getItemCount and dropdown.setSelectedIndex then
        for i = 1, dropdown:getItemCount() do
            if dropdown:getItem(i) == value then
                dropdown:setSelectedIndex(i)
                return
            end
        end
    end
end

function utils.loadConfig(configFile)
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

function utils.saveConfig(cfg)
    local f = fs.open(configFile, "w")
    for k, v in pairs(cfg) do
        f.writeLine(k .. "=" .. tostring(v))
    end
    f.close()
end



return utils