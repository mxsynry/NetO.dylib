local Timeline = {}
Timeline.__index = Timeline

function Timeline.new(maxEntries)
    return setmetatable({
        Entries = {},
        MaxEntries = maxEntries or 512,
        StartedAt = os.clock(),
    }, Timeline)
end

function Timeline:Push(kind, payload)
    local entry = {
        t = os.clock() - self.StartedAt,
        kind = kind,
        payload = payload,
    }

    table.insert(self.Entries, entry)

    while #self.Entries > self.MaxEntries do
        table.remove(self.Entries, 1)
    end

    return entry
end

function Timeline:AttachTracker(name, tracker)
    return tracker.Changed:Connect(function(current, previous)
        self:Push("state", {
            name = name,
            current = current,
            previous = previous,
        })
    end)
end

function Timeline:Clear()
    table.clear(self.Entries)
    self.StartedAt = os.clock()
end

return Timeline
