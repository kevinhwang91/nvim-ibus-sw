local cmd = vim.cmd

local M = {}
local initialized = false

-- TODO
function M.enable()
    if not initialized then
        return false
    end
end

-- TODO
function M.disable()
    if not initialized then
        return false
    end
end

function M.setup()
    if initialized then
        return
    end
    M.initialize()
    initialized = true
end

function M.initialize()
    if vim.env.SSH_CONNECTION or vim.env.SUDO_USER then
        return
    end
    local engine = require('ibus-sw.engine')
    local switcher = require('ibus-sw.switcher'):initialize()
    switcher:getInputSize(function(code, res)
        vim.schedule(function()
            if code == 0 then
                if res and res > 1 then
                    engine:initialize(switcher)
                end
            else
                local ibus = require('ibus-sw.ibus'):initialize()
                if ibus then
                    engine = require('ibus-sw.engine'):initialize(ibus)
                end
            end
            if not engine.initialized then
                return
            end
            cmd([[
                aug IbusSw
                    au!
                    au InsertEnter * lua require('ibus-sw.engine'):setInput(true)
                    au InsertLeave * lua require('ibus-sw.engine'):setInput(false)
                aug END
            ]])
        end)
    end)
end

return M
