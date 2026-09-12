local Assembly = {}

function Assembly.GetRoot(part)
    if not part or not part:IsA("BasePart") then
        return nil
    end

    local ok, root = pcall(function()
        return part.AssemblyRootPart
    end)

    if ok and root then
        return root
    end

    return part
end

function Assembly.DistanceFrom(part, reference)
    if not part or not reference then
        return nil
    end

    local ok, distance = pcall(function()
        return (part.Position - reference.Position).Magnitude
    end)

    if ok then
        return distance
    end

    return nil
end

function Assembly.GetVelocities(part)
    if not part then
        return nil, nil
    end

    local linear, angular

    pcall(function()
        linear = part.AssemblyLinearVelocity
    end)

    pcall(function()
        angular = part.AssemblyAngularVelocity
    end)

    return linear, angular
end

return Assembly
