# Theory and research model

## NetO is not RakNet

NetO sits above Roblox's native networking implementation.

It does not expose:

- RakNet datagrams
- ACK/NACK queues
- ordering channels
- native peer IDs
- reliability-layer internals
- arbitrary ownership transfer

The name "Dynamic Library" describes the architecture: consumers depend on a reusable runtime interface.

## What `NetworkOwnerV3` is used for here

Only as an observation.

Current sUNC documentation demonstrates reading the property and reports a `SystemAddress`-compatible value.

NetO does not assume:

```text
writing NetworkOwnerV3
        =
native network ownership transfer
```

That equivalence has not been established.

## Useful experiments

A safe experiment compares state sequences:

```text
normal movement
    vs
sit
    vs
ragdoll
    vs
large root distance
```

For each assembly, record:

```text
time
owner descriptor
ownership rule
sleeping
ReceiveAge
linear/angular velocity
distance from HRP
```

The useful question is causality:

> Which observable state changes first when an assembly begins to drift or become stale?

## Future read-only directions

Potential 0.2 additions:

- ownership-transition event adapter where accessible;
- per-assembly health scoring;
- CSV/JSON timeline export;
- R6 character group labeling;
- accessory/handle grouping;
- state histograms;
- two-client comparison format.

Any active mutation layer should remain separate from the observation library so NetO's measurements do not alter the system it is measuring.
