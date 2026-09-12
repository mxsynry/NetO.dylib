--[[
    NetO Dynamic Library 0.1.0-theoretical
    Standalone read-only build.

    Optional sUNC:
      gethiddenproperty
      getthreadidentity

    This build does NOT invoke:
      sethiddenproperty
      setscriptable
      setthreadidentity
      replicatesignal
      hookmetamethod
]]

local RunService = game:GetService("RunService")

local NetO = {
    Name = "NetO Dynamic Library",
    Version = "0.1.0-theoretical",
    ABI = 1,
    ReadOnly = true,
}

local function readProperty(instance, property)
    local ok, value = pcall(function()
        return instance[property]
    end)

    if ok then
        return true, value, false
    end

    if type(gethiddenproperty) == "function" then
        local hiddenOk, hiddenValue, hiddenFlag = pcall(gethiddenproperty, instance, property)

        if hiddenOk then
            return true, hiddenValue, hiddenFlag == true
        end
    end

    return false, nil, false
end

local function read(instance, property)
    local ok, value, hidden = readProperty(instance, property)
    return value, ok, hidden
end

local function getRoot(part)
    if not part or not part:IsA("BasePart") then
        return nil
    end

    local ok, root = pcall(function()
        return part.AssemblyRootPart
    end)

    return (ok and root) or part
end

local function distanceFrom(part, reference)
    if not part or not reference then
        return nil
    end

    local ok, value = pcall(function()
        return (part.Position - reference.Position).Magnitude
    end)

    return ok and value or nil
end

local function stringify(value)
    if value == nil then
        return nil
    end

    local ok, result = pcall(tostring, value)
    return ok and result or "<unprintable>"
end

local function classify(snapshot, staleAge)
    staleAge = staleAge or 0.25

    if not snapshot.Part or not snapshot.Root then
        return "INVALID"
    end

    if snapshot.Sleeping == true then
        return "SLEEPING"
    end

    if type(snapshot.ReceiveAge) == "number" and snapshot.ReceiveAge > staleAge then
        return "STALE"
    end

    return "ACTIVE"
end

function NetO.GetCapabilities()
    return {
        HiddenProperties = type(gethiddenproperty) == "function",
        ThreadIdentityReadable = type(getthreadidentity) == "function",

        -- Reported only. NetO 0.1 does not invoke these:
        HiddenPropertyWritable = type(sethiddenproperty) == "function",
        ScriptabilityMutable = type(setscriptable) == "function",
        ThreadIdentityMutable = type(setthreadidentity) == "function",
        ReplicateSignal = type(replicatesignal) == "function",
    }
end

function NetO.GetThreadIdentity()
    if type(getthreadidentity) ~= "function" then
        return nil
    end

    local ok, identity = pcall(getthreadidentity)
    return ok and identity or nil
end

function NetO.Probe(part, options)
    options = options or {}

    local root = getRoot(part)

    if not root then
        return {
            Part = part,
            Root = nil,
            Name = part and part.Name or "<nil>",
            State = "INVALID",
        }
    end

    local owner, ownerReadable, ownerHidden = read(root, "NetworkOwnerV3")
    local sleeping, sleepReadable, sleepHidden = read(root, "NetworkIsSleeping")
    local rule, ruleReadable, ruleHidden = read(root, "NetworkOwnershipRule")
    local age, ageReadable, ageHidden = read(root, "ReceiveAge")

    local linear, angular

    pcall(function()
        linear = root.AssemblyLinearVelocity
        angular = root.AssemblyAngularVelocity
    end)

    local snapshot = {
        Name = part:GetFullName(),
        Part = part,
        Root = root,

        Owner = owner,
        OwnerString = stringify(owner),
        OwnerReadable = ownerReadable,
        OwnerHidden = ownerHidden,

        Sleeping = sleeping,
        SleepingReadable = sleepReadable,
        SleepingHidden = sleepHidden,

        Rule = rule,
        RuleString = stringify(rule),
        RuleReadable = ruleReadable,
        RuleHidden = ruleHidden,

        ReceiveAge = age,
        ReceiveAgeReadable = ageReadable,
        ReceiveAgeHidden = ageHidden,

        LinearVelocity = linear,
        AngularVelocity = angular,

        Distance = distanceFrom(root, options.Reference),
        Timestamp = os.clock(),
    }

    snapshot.State = classify(snapshot, options.StaleAge)

    return snapshot
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({_listeners = {}}, Signal)
end

function Signal:Connect(callback)
    local signal = self
    local token = {}
    signal._listeners[token] = callback

    return {
        Disconnect = function()
            signal._listeners[token] = nil
        end,
    }
end

function Signal:Fire(...)
    for _, callback in pairs(self._listeners) do
        task.spawn(callback, ...)
    end
end

function Signal:Destroy()
    table.clear(self._listeners)
end

local Tracker = {}
Tracker.__index = Tracker

local function changed(a, b)
    if not a or not b then
        return true
    end

    return a.State ~= b.State
        or a.OwnerString ~= b.OwnerString
        or a.RuleString ~= b.RuleString
        or a.Sleeping ~= b.Sleeping
        or math.abs((a.ReceiveAge or 0) - (b.ReceiveAge or 0)) >= 0.05
end

function Tracker.new(part, options)
    options = options or {}

    return setmetatable({
        Part = part,
        Reference = options.Reference,
        Interval = options.Interval or 0.10,
        StaleAge = options.StaleAge or 0.25,
        Changed = Signal.new(),
        Current = nil,
        _connection = nil,
        _accumulator = 0,
    }, Tracker)
end

function Tracker:Step()
    local previous = self.Current
    local current = NetO.Probe(self.Part, {
        Reference = self.Reference,
        StaleAge = self.StaleAge,
    })

    self.Current = current

    if changed(current, previous) then
        self.Changed:Fire(current, previous)
    end

    return current
end

function Tracker:Start()
    if self._connection then
        return self
    end

    self:Step()

    self._connection = RunService.Heartbeat:Connect(function(dt)
        self._accumulator += dt

        if self._accumulator >= self.Interval then
            self._accumulator = 0
            self:Step()
        end
    end)

    return self
end

function Tracker:Stop()
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end

    return self
end

function Tracker:Destroy()
    self:Stop()
    self.Changed:Destroy()
end

function NetO.Track(part, options)
    return Tracker.new(part, options)
end

function NetO.ProfileCharacter(character)
    local report = {}

    if not character then
        return report
    end

    local reference = character:FindFirstChild("HumanoidRootPart")

    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            table.insert(report, NetO.Probe(descendant, {
                Reference = reference,
            }))
        end
    end

    table.sort(report, function(a, b)
        return (a.Name or "") < (b.Name or "")
    end)

    return report
end

function NetO.FormatSnapshot(snapshot)
    if not snapshot then
        return "NetO<nil>"
    end

    return string.format(
        "NetO<%s state=%s owner=%s rule=%s sleeping=%s age=%s distance=%s>",
        tostring(snapshot.Name),
        tostring(snapshot.State),
        tostring(snapshot.OwnerString),
        tostring(snapshot.RuleString),
        tostring(snapshot.Sleeping),
        tostring(snapshot.ReceiveAge),
        tostring(snapshot.Distance)
    )
end

return NetO
