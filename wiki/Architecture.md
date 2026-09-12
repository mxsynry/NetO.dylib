# Architecture

```text
              consumer
                 │
                 ▼
              NetO API
                 │
       ┌─────────┼─────────┐
       ▼         ▼         ▼
    Tracker   Profiler   Timeline
       │         │
       └────┬────┘
            ▼
          Probe
            │
    ┌───────┼────────┐
    ▼       ▼        ▼
 Assembly  Hidden  Snapshot
    │       │
    │       ▼
    │    Adapter
    │   ┌───┴────┐
    │   ▼        ▼
    │  sUNC   Vanilla
    │
    ▼
 Roblox assembly physics
```

## Adapter layer

The adapter is responsible for one thing: safely attempting a read.

NetO currently ships:

- `Vanilla` — direct property access only.
- `sUNC` — direct access first, then `gethiddenproperty`.

No adapter writes hidden properties in 0.1.

## Assembly normalization

The caller can pass an accessory handle or any `BasePart`.

NetO resolves:

```lua
part.AssemblyRootPart
```

and treats the assembly root as the physics observation unit.

This avoids pretending that every Instance in one rigid assembly has independent network ownership.

## Snapshots

A snapshot contains raw observations plus a derived state.

Current state classifier:

```text
missing part/root -> INVALID
NetworkIsSleeping == true -> SLEEPING
ReceiveAge > stale threshold -> STALE
otherwise -> ACTIVE
```

This is intentionally conservative. It does not classify `Owner` values as "local" or "remote" without an explicit mapping.
