local Vanilla = {}

Vanilla.Name = "Vanilla"
Vanilla.SupportsHiddenProperties = false

function Vanilla.ReadProperty(instance, property)
    local ok, value = pcall(function()
        return instance[property]
    end)

    if ok then
        return true, value, false
    end

    return false, nil, false
end

function Vanilla.GetIdentity()
    return nil
end

return Vanilla
