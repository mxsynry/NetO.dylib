local Hidden = {}

local function read(adapter, instance, property)
    if not adapter or not instance then
        return nil, false, false
    end

    local ok, value, hidden = adapter.ReadProperty(instance, property)
    return value, ok, hidden
end

function Hidden.NetworkOwnerV3(adapter, part)
    return read(adapter, part, "NetworkOwnerV3")
end

function Hidden.NetworkIsSleeping(adapter, part)
    return read(adapter, part, "NetworkIsSleeping")
end

function Hidden.NetworkOwnershipRule(adapter, part)
    return read(adapter, part, "NetworkOwnershipRule")
end

function Hidden.ReceiveAge(adapter, part)
    return read(adapter, part, "ReceiveAge")
end

return Hidden
