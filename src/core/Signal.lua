local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({
        _listeners = {},
        _destroyed = false,
    }, Signal)
end

function Signal:Connect(callback)
    assert(type(callback) == "function", "callback must be a function")

    local listeners = self._listeners
    local token = {}
    listeners[token] = callback

    local connection = {}

    function connection:Disconnect()
        listeners[token] = nil
    end

    return connection
end

function Signal:Fire(...)
    if self._destroyed then
        return
    end

    for _, callback in pairs(self._listeners) do
        task.spawn(callback, ...)
    end
end

function Signal:Destroy()
    self._destroyed = true
    table.clear(self._listeners)
end

return Signal
