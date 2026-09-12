local NetO = loadstring(readfile("NetO.lua"))()

local Players = game:GetService("Players")
local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

for _, snapshot in ipairs(NetO.ProfileCharacter(character)) do
    print(
        snapshot.Name,
        snapshot.State,
        snapshot.OwnerString,
        snapshot.RuleString,
        snapshot.Sleeping,
        snapshot.ReceiveAge,
        snapshot.Distance
    )
end

local tracker = NetO.Track(root, {
    Reference = root,
    Interval = 0.10,
})

tracker.Changed:Connect(function(current, previous)
    print("[NetO]", NetO.FormatSnapshot(current))
end)

tracker:Start()
