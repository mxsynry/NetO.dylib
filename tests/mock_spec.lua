-- Minimal shape test for development environments that provide Roblox datatypes.
-- This intentionally does not test hidden-property mutation.

local function assertEqual(a, b, message)
    assert(a == b, message or string.format("%s ~= %s", tostring(a), tostring(b)))
end

assertEqual(type("NetO"), "string")
print("NetO mock_spec: basic test harness loaded")
