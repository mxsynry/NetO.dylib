# NetO Wiki

NetO Dynamic Library is a theoretical read-only observation layer for Roblox network ownership and assembly physics.

Start here:

- [Requirements](Requirements.md)
- [Security Contexts](Security-Contexts.md)
- [Architecture](Architecture.md)
- [API](API.md)
- [Theory](Theory.md)

## Design rule

NetO 0.1 observes. It does not claim to control native RakNet or Roblox server authority.

The library normalizes a `BasePart` to its `AssemblyRootPart`, reads public physics state, optionally reads hidden properties through a supported reflection API, and produces a consistent snapshot.
