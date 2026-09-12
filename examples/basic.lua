local NetO = loadstring(readfile("NetO.lua"))()

print("NetO", NetO.Version)
print("Identity", NetO.GetThreadIdentity())

for key, value in pairs(NetO.GetCapabilities()) do
    print(key, value)
end

local Players = game:GetService("Players")
local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local snapshot = NetO.Probe(root, {
    Reference = root,
})

print(NetO.FormatSnapshot(snapshot))
