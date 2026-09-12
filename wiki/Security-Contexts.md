# Roblox security contexts and thread identity

This page intentionally distinguishes Roblox API security from executor thread identity.

## Roblox member security

Roblox API members may carry security metadata such as:

- `None`
- `LocalUserSecurity`
- `PluginSecurity`
- `RobloxScriptSecurity`
- `RobloxSecurity`

These labels belong to the Roblox engine/API surface.

As of the API snapshot used for NetO 0.1:

| Member | Relevant metadata |
|---|---|
| `BasePart.NetworkOwnerV3` | `Hidden`, `NotScriptable` |
| `BasePart.NetworkIsSleeping` | `Hidden`, `NotScriptable` |
| `BasePart.NetworkOwnershipRule` | `Hidden`, `NotScriptable` |
| `BasePart.NetworkOwnerChanged` | `Hidden`, `LocalUserSecurity` |
| `BasePart.ReceiveAge` | `Hidden`, `ReadOnly`, `NotReplicated` |
| `BasePart.ReplicationPV` | `Hidden`, `NotScriptable`, `RobloxSecurity` |

Reference:

https://robloxapi.github.io/ref/class/BasePart.html

## Hidden is not the same as a security level

`Hidden`, `NotScriptable`, `ReadOnly`, and `NotReplicated` are metadata characteristics, not interchangeable security identities.

For example, a member may be hidden and non-scriptable without a displayed member security level.

## Executor thread identity

sUNC defines:

```lua
getthreadidentity(): number
setthreadidentity(id: number)
```

Its documentation says `setthreadidentity` changes the current Luau thread identity and matching capabilities.

References:

https://docs.sunc.io/Reflection/getthreadidentity/
https://docs.sunc.io/Reflection/setthreadidentity/

## NetO policy

NetO does **not** assign a magic required identity number.

Why:

1. numeric identities are an executor/runtime mechanism, not a portable Roblox API contract;
2. individual executor implementations differ;
3. `gethiddenproperty` is the capability NetO needs, not identity mutation itself;
4. raising identity does not prove that a native network-owner change will be authoritative.

So the effective requirement is:

> the current environment must be able to read the requested property through the adapter.

If that requires an executor to internally use a particular identity, that is the executor's implementation detail.

NetO 0.1 never calls `setthreadidentity`.
