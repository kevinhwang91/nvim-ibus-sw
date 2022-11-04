local uv = vim.loop

local Engine = {
}
Engine.__index = Engine

function Engine.execute(path, args, cb)
    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)
    local handle
    local resBuf, errBuf = {}, {}
    handle = uv.spawn(path, {
        args = args,
        stdio = {nil, stdout, stderr},
    }, function(code, signal)
        handle:close()
        if type(cb) == 'function' then
            local res = table.concat(code == 0 and resBuf or errBuf, '')
            cb(code, res, signal)
        end
    end)
    stdout:read_start(function(err, data)
        assert(not err, err)
        if data then
            table.insert(resBuf, data)
        else
            stdout:close()
        end
    end)
    stderr:read_start(function(err, data)
        assert(not err, err)
        if data then
            table.insert(errBuf, data)
        else
            stderr:close()
        end
    end)
end

function Engine:setInput(enterInsert, cb)
    self.module:setInput(enterInsert, cb)
end

function Engine:initialize(module)
    self.module = module
    module:getInput()
    self.initialized = true
    return self.module
end

return Engine
