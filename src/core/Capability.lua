local Capability = {}

function Capability.Detect(adapter)
    local caps = {
        Adapter = adapter and adapter.Name or "Unknown",
        HiddenProperties = adapter and adapter.SupportsHiddenProperties == true or false,
        ThreadIdentityReadable = type(getthreadidentity) == "function",
        HiddenPropertyWritable = type(sethiddenproperty) == "function",
        ScriptabilityMutable = type(setscriptable) == "function",
        ThreadIdentityMutable = type(setthreadidentity) == "function",
        ReplicateSignal = type(replicatesignal) == "function",
    }

    -- Presence is reported for diagnostics only.
    -- NetO 0.1 intentionally does not consume the write/elevation primitives.
    return caps
end

return Capability
