# NetO.dylib

**NetO Dynamic Library**

**NetO** is a theoretical, read-only network-ownership and physics-observation library for Roblox research.

The project is intentionally structured like a small runtime library: a root bootstrap, focused source modules, diagnostics, examples, documentation, and a generated single-file distribution target.

> NetO does **not** implement RakNet, seize network ownership, bypass server authority, or claim that changing a hidden property changes native replication authority. Version 0.1 is observational by design.

## What NetO observes

NetO builds a state view around a `BasePart` / assembly:

- `AssemblyRootPart`
- `AssemblyLinearVelocity`
- `AssemblyAngularVelocity`
- `ReceiveAge`
- `NetworkOwnerV3` when a supported reflection API is available
- `NetworkIsSleeping` when available
- `NetworkOwnershipRule` when available
- distance from a reference root
- state transitions and diagnostic timelines

The point is to answer questions such as:

- Which assembly actually represents this accessory?
- Did ownership state change before a physics failure?
- Did `ReceiveAge` become stale before visible drift?
- Did a part enter a sleeping state?
- Do two reanimation modes produce different ownership profiles?

## Repository layout

```text
NetO-Dynamic-Library/
├── init.lua
├── NetO.lua
├── src/
│   ├── NetO.lua
│   ├── adapters/
│   │   ├── sUNC.lua
│   │   └── Vanilla.lua
│   ├── core/
│   │   ├── Assembly.lua
│   │   ├── Capability.lua
│   │   ├── Hidden.lua
│   │   ├── Signal.lua
│   │   ├── Snapshot.lua
│   │   └── Tracker.lua
│   └── diagnostics/
│       ├── Profiler.lua
│       └── Timeline.lua
├── examples/
│   ├── basic.lua
│   └── character.lua
├── docs/
│   └── index.html
├── wiki/
│   ├── Home.md
│   ├── API.md
│   ├── Architecture.md
│   ├── Requirements.md
│   ├── Security-Contexts.md
│   └── Theory.md
├── tests/
│   └── mock_spec.lua
├── tools/
│   └── build.py
├── LICENSE
└── .gitignore
```

## Quick start

### Single-file build

`NetO.lua` is the distributable form.

```lua
local NetO = loadstring(readfile("NetO.lua"))()

local Players = game:GetService("Players")
local character = Players.LocalPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")

if root then
    local snapshot = NetO.Probe(root)
    print(NetO.FormatSnapshot(snapshot))
end
```

### Track an assembly

```lua
local tracker = NetO.Track(part, {
    Reference = character:FindFirstChild("HumanoidRootPart"),
    Interval = 0.10,
})

tracker.Changed:Connect(function(current, previous)
    print(current.State, current.ReceiveAge, current.Distance)
end)

tracker:Start()
```

### Character profile

```lua
local report = NetO.ProfileCharacter(game:GetService("Players").LocalPlayer.Character)

for _, entry in ipairs(report) do
    print(entry.Name, entry.State, entry.Owner)
end
```

## Requirements

### Minimum Roblox API

No executor-specific feature is needed for the public physics fields. NetO can still report:

- assembly root
- linear/angular velocity
- position/distance
- direct-readable `ReceiveAge` where the runtime permits it

### Optional sUNC capability

For the full hidden-state profile NetO checks for:

```lua
gethiddenproperty
```

No hidden-property **write** API is required by NetO 0.1.

NetO does not require:

```lua
sethiddenproperty
setscriptable
setthreadidentity
replicatesignal
hookmetamethod
```

Those are deliberately outside the 0.1 runtime.

See [`wiki/Requirements.md`](wiki/Requirements.md) and [`wiki/Security-Contexts.md`](wiki/Security-Contexts.md).

## Security / identity model

NetO separates three concepts that are often mixed together:

1. **Roblox member security tags** such as `LocalUserSecurity` or `RobloxSecurity`.
2. **Scriptability metadata** such as `Hidden`, `NotScriptable`, `ReadOnly`, and `NotReplicated`.
3. **Executor thread identity**, which is implementation-specific and is not treated as a portable permission guarantee.

NetO therefore capability-tests every optional read instead of assuming a numeric identity level grants a feature.

## Current status

`0.1.0-theoretical`

- read-only probing
- assembly normalization
- hidden-property adapter
- snapshot state classifier
- lightweight polling tracker
- transition signal
- timeline recorder
- character profiler
- HTML + Markdown documentation

## References

- Roblox BasePart API: https://robloxapi.github.io/ref/class/BasePart.html
- sUNC `gethiddenproperty`: https://docs.sunc.io/Reflection/gethiddenproperty/
- sUNC `getthreadidentity`: https://docs.sunc.io/Reflection/getthreadidentity/
- sUNC `setthreadidentity`: https://docs.sunc.io/Reflection/setthreadidentity/

## Scope

Use NetO for diagnostics, testing, compatibility research, and understanding client-visible physics state. Do not treat a locally writable descriptor as evidence of server-side authority.

## License

MPL-2.0. See `LICENSE` in the repository.
