# Requirements

## Runtime

NetO targets client-side Roblox Luau.

### Baseline

The library expects:

- `game`
- `BasePart`
- `AssemblyRootPart`
- `AssemblyLinearVelocity`
- `AssemblyAngularVelocity`
- `RunService.Heartbeat`
- `task.spawn`

### Optional sUNC

Full hidden-property observation requires:

```lua
gethiddenproperty(instance, property)
```

Current sUNC documentation says this can retrieve hidden/non-scriptable values, including `SystemAddress`, and specifically demonstrates `NetworkOwnerV3`.

Reference:

https://docs.sunc.io/Reflection/gethiddenproperty/

### Optional identity read

```lua
getthreadidentity()
```

NetO may report the current identity for diagnostics, but does not change it.

Reference:

https://docs.sunc.io/Reflection/getthreadidentity/

## Explicitly not required by NetO 0.1

```lua
sethiddenproperty
setscriptable
setthreadidentity
replicatesignal
hookmetamethod
getconnections
```

NetO capability-detects some of these so a diagnostic report can describe the environment, but 0.1 does not invoke them.

## Why capability testing beats executor-name testing

Two executors can expose the same function name with different behavior. NetO therefore:

1. detects function presence;
2. wraps each optional operation in `pcall`;
3. degrades to partial snapshots;
4. never equates a function name with actual server/network authority.
