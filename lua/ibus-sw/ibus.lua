local fn = vim.fn

local Engine = require('ibus-sw.engine')

local Ibus = setmetatable({}, Engine)

function Ibus:getInput(cb)
    self.execute(self.path, self.getInputArgs, function(code, res)
        assert(code == 0, res)
        res = vim.trim(res)
        self.nCache = res
        self.iCache = res
        if type(cb) == 'function' then
            cb(res)
        end
    end)
end

function Ibus:setInput(enterInsert, cb)
    local source = enterInsert and self.iCache or self.nCache
    self:getInput(function(previousSource)
        if previousSource ~= source then
            self.setInputArgs[#self.setInputArgs] = source
            self.execute(self.path, self.setInputArgs)
        end
        if type(cb) == 'function' then
            cb(previousSource)
        end
    end)
end

function Ibus:initialize()
    self.path = 'ibus'
    if fn.executable(self.path) == 0 then
        return nil
    end
    self.getInputArgs = {'engine'}
    self.setInputArgs = {'engine', ''}
    return self
end

return Ibus
