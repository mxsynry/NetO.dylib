local Profiler = {}

function Profiler.Character(character, probe)
    local report = {}

    if not character then
        return report
    end

    local reference = character:FindFirstChild("HumanoidRootPart")

    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            local snapshot = probe(descendant, {
                Reference = reference,
            })

            table.insert(report, snapshot)
        end
    end

    table.sort(report, function(a, b)
        return (a.Name or "") < (b.Name or "")
    end)

    return report
end

return Profiler
