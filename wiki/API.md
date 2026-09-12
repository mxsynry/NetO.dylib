# API

## Metadata

```lua
NetO.Name
NetO.Version
NetO.ABI
NetO.ReadOnly
```

## `NetO.GetCapabilities()`

Returns environment capability presence.

```lua
local caps = NetO.GetCapabilities()
```

Important: presence is not proof of semantic correctness or server authority.

## `NetO.GetThreadIdentity()`

Returns the current identity when `getthreadidentity` exists, otherwise `nil`.

This is diagnostic only.

## `NetO.Probe(part, options?)`

Produces one snapshot.

Options:

```lua
{
    Reference = BasePart?, -- distance reference
    StaleAge = number?,    -- default 0.25 s
}
```

Selected snapshot fields:

```lua
{
    Name,
    Part,
    Root,

    Owner,
    OwnerString,
    OwnerReadable,
    OwnerHidden,

    Sleeping,
    SleepingReadable,
    SleepingHidden,

    Rule,
    RuleString,
    RuleReadable,
    RuleHidden,

    ReceiveAge,
    ReceiveAgeReadable,
    ReceiveAgeHidden,

    LinearVelocity,
    AngularVelocity,
    Distance,
    State,
    Timestamp,
}
```

## `NetO.Track(part, options?)`

Creates a polling tracker.

```lua
local tracker = NetO.Track(part, {
    Interval = 0.10,
    Reference = root,
    StaleAge = 0.25,
})

tracker.Changed:Connect(function(current, previous)
    -- diagnostic response
end)

tracker:Start()
tracker:Stop()
tracker:Destroy()
```

## `NetO.ProfileCharacter(character)`

Returns snapshots for all `BasePart` descendants of a character.

## `NetO.FormatSnapshot(snapshot)`

Produces a compact debug string.
