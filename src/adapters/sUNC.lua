local Adapter = {}

Adapter.Name = "sUNC"
Adapter.SupportsHiddenProperties = type(gethiddenproperty) == "function"

function Adapter.ReadProperty(instance, property)
    -- Try normal access first. Hidden does not necessarily mean unreadable.
    local ok, value = pcall(function()
        return instance[property]
    end)

    if ok then
        return true, value, false
    end

    if type(gethiddenproperty) ~= "function" then
        return false, nil, false
    end

    local hiddenOk, hiddenValue, hiddenFlag = pcall(gethiddenproperty, instance, property)
    if hiddenOk then
        return true, hiddenValue, hiddenFlag == true
    end

    return false, nil, false
end

function Adapter.GetIdentity()
    if type(getthreadidentity) ~= "function" then
        return nil
    end

    local ok, value = pcall(getthreadidentity)
    if ok then
        return value
    end

    return nil
end

return Adapter
