local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Signal)

local Tracker = {}
Tracker.__index = Tracker

local function materiallyChanged(a, b)
    if not a or not b then
        return true
    end

    return a.State ~= b.State
        or a.OwnerString ~= b.OwnerString
        or a.RuleString ~= b.RuleString
        or a.Sleeping ~= b.Sleeping
        or math.abs((a.ReceiveAge or 0) - (b.ReceiveAge or 0)) >= 0.05
end

function Tracker.new(probe, part, options)
    options = options or {}

    return setmetatable({
        _probe = probe,
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
    local current = self._probe(self.Part, {
        Reference = self.Reference,
        StaleAge = self.StaleAge,
    })

    self.Current = current

    if materiallyChanged(current, previous) then
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

return Tracker
