local sUNC = require(script.adapters.sUNC)
local Vanilla = require(script.adapters.Vanilla)

local Capability = require(script.core.Capability)
local Hidden = require(script.core.Hidden)
local Assembly = require(script.core.Assembly)
local Snapshot = require(script.core.Snapshot)
local Tracker = require(script.core.Tracker)
local Timeline = require(script.diagnostics.Timeline)
local Profiler = require(script.diagnostics.Profiler)

local NetO = {}

NetO.Name = "NetO Dynamic Library"
NetO.Version = "0.1.0-theoretical"
NetO.ABI = 1
NetO.ReadOnly = true

local adapter = sUNC.SupportsHiddenProperties and sUNC or Vanilla

function NetO.GetAdapter()
    return adapter.Name
end

function NetO.GetCapabilities()
    return Capability.Detect(adapter)
end

function NetO.GetThreadIdentity()
    return adapter.GetIdentity()
end

function NetO.Probe(part, options)
    options = options or {}

    if not part or not part:IsA("BasePart") then
        return Snapshot.Normalize({
            Part = part,
            Root = nil,
            Name = part and part.Name or "<nil>",
            State = "INVALID",
        })
    end

    local root = Assembly.GetRoot(part)
    local linear, angular = Assembly.GetVelocities(root)

    local owner, ownerReadable, ownerHidden = Hidden.NetworkOwnerV3(adapter, root)
    local sleeping, sleepReadable, sleepHidden = Hidden.NetworkIsSleeping(adapter, root)
    local rule, ruleReadable, ruleHidden = Hidden.NetworkOwnershipRule(adapter, root)
    local receiveAge, ageReadable, ageHidden = Hidden.ReceiveAge(adapter, root)

    local snapshot = {
        Name = part:GetFullName(),
        Part = part,
        Root = root,

        Owner = owner,
        OwnerReadable = ownerReadable,
        OwnerHidden = ownerHidden,

        Sleeping = sleeping,
        SleepingReadable = sleepReadable,
        SleepingHidden = sleepHidden,

        Rule = rule,
        RuleReadable = ruleReadable,
        RuleHidden = ruleHidden,

        ReceiveAge = receiveAge,
        ReceiveAgeReadable = ageReadable,
        ReceiveAgeHidden = ageHidden,

        LinearVelocity = linear,
        AngularVelocity = angular,

        Distance = Assembly.DistanceFrom(root, options.Reference),
        StaleAge = options.StaleAge,
        Timestamp = os.clock(),
    }

    return Snapshot.Normalize(snapshot)
end

function NetO.Track(part, options)
    return Tracker.new(NetO.Probe, part, options)
end

function NetO.NewTimeline(maxEntries)
    return Timeline.new(maxEntries)
end

function NetO.ProfileCharacter(character)
    return Profiler.Character(character, NetO.Probe)
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
