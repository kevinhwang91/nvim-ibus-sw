local Engine = require('ibus-sw.engine')

local ExtensionSwitcher = setmetatable({}, Engine)

function ExtensionSwitcher:getInputSize(cb)
    local f = type(cb) == 'function' and function(code, res)
        if code == 0 and type(res) == 'string' then
            for s in vim.gsplit(res, '%s+') do
                res = tonumber(s)
                if type(res) == 'number' then
                    break
                end
            end
        end
        cb(code, res)
    end or nil
    self.execute(self.path, self.getInputSizeArgs, f)
end

function ExtensionSwitcher:getInput(cb)
    self.execute(self.path, self.getInputArgs, function(code, res)
        assert(code == 0, res)
        self.nCache = res
        self.iCache = res
        if type(cb) == 'function' then
            cb(code, res)
        end
    end)
end

function ExtensionSwitcher:setInput(enterInsert, cb)
    local cache = enterInsert and self.iCache or self.nCache
    local index, mode = cache:match('^%s+(%d+)|(.*)')
    self.setInputArgs[#self.setInputArgs - 1] = 'uint32:' .. index
    self.setInputArgs[#self.setInputArgs] = 'string:' .. mode
    self.execute(self.path, self.setInputArgs, function(code, res)
        assert(code == 0, res)
        if enterInsert then
            self.nCache = res
        else
            self.iCache = res
        end
        if type(cb) == 'function' then
            cb(code, res)
        end
    end)
end

function ExtensionSwitcher:initialize()
    self.path = 'dbus-send'
    local shellInterface = 'org.gnome.Shell.Extensions.IbusSwitcher'
    local commonArgs = {
        '--session', '--type=method_call', '--print-reply=literal',
        '--dest=org.gnome.Shell', '/org/gnome/Shell/Extensions/IbusSwitcher'
    }

    self.getInputSizeArgs = vim.deepcopy(commonArgs)
    self.getInputArgs = vim.deepcopy(commonArgs)
    self.setInputArgs = vim.deepcopy(commonArgs)
    table.insert(self.getInputSizeArgs, shellInterface .. '.SourceSize')
    table.insert(self.getInputArgs, shellInterface .. '.CurrentSource')
    table.insert(self.setInputArgs, shellInterface .. '.SwitchSource')
    table.insert(self.setInputArgs, '')
    table.insert(self.setInputArgs, '')
    return self
end

return ExtensionSwitcher
