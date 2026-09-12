local Snapshot = {}

local DEFAULT_STALE_AGE = 0.25

local function stringify(value)
    if value == nil then
        return nil
    end

    local ok, result = pcall(tostring, value)
    return ok and result or "<unprintable>"
end

function Snapshot.Classify(data, staleAge)
    staleAge = staleAge or DEFAULT_STALE_AGE

    if data.Sleeping == true then
        return "SLEEPING"
    end

    if type(data.ReceiveAge) == "number" and data.ReceiveAge > staleAge then
        return "STALE"
    end

    if data.Part == nil or data.Root == nil then
        return "INVALID"
    end

    return "ACTIVE"
end

function Snapshot.Normalize(data)
    data.OwnerString = stringify(data.Owner)
    data.RuleString = stringify(data.Rule)
    data.State = Snapshot.Classify(data, data.StaleAge)
    return data
end

return Snapshot
