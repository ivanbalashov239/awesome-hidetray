---------------------------------------------------------------------------
-- @author Ivan Balashov
-- @copyright 2015 Ivan Balashov
---------------------------------------------------------------------------

local wbase = require("wibox.widget.base")
local naughty = require("naughty")
local wconst = require("wibox.layout.constraint")
local lbase = require("wibox.layout.base")
local awfwibox = require("awful.wibox")
local beautiful = require("beautiful")
local systray	 = require("systray")
local capi = { awesome = awesome }
local setmetatable = setmetatable
local error = error
local abs = math.abs

--- wibox.widget.hidetray
local hidetray = { mt = {} }

hidetray.table = {}

function hidetray:show(s)
    hidetray.hidetimer:stop()
    for i,k in pairs(hidetray.table) do
        if not i == s then
            hidetray:hide(i)
        else
            hidetray.traybufer:set_widget(nil)
            hidetray.table[s]:set_widget(hidetray.tray)
        end
    end
end
function hidetray:hide(s)
    hidetray.traybufer:set_widget(hidetray.tray)
    hidetray.table[s]:reset()
end

function hidetray:attach(args)
    local args = args or {}
    local wib = args.wibox
    local revers = args.revers
    local s = args.screen or 1
    if wib then
        wib:connect_signal('mouse::enter', function () 
            hidetray:show(s)
        end)
        wib:connect_signal('mouse::leave', function ()
            if (mouse.object_under_pointer() and mouse.object_under_pointer().name ) or mouse.screen ~= s then 
                hidetray:hide(s)
            else
                hidetray.hidetimer:start()
            end
        end)
    end
end

local function newtable(args)
    local args = args or {}
    local number = args.number or screen.count()
    local backgr = args.background or wconst
    local gettimerscreen = args.focusscreen or function() return mouse.screen end
    hidetray.traybufer = args.traybufer or awfwibox({ x = -55, y = -55})
    hidetray.hidetimer = timer({ timeout = args.timeout or 5 })
    hidetray.hidetimer:connect_signal("timeout", function ()
        for s = 1, number do
            hidetray:hide(s)
        end
        hidetray.hidetimer:stop()
    end)
    awesome.connect_signal("systray::update", function()
        hidetray:show(gettimerscreen())
        hidetray.hidetimer:start()
    end)

    for s =  1, number do
        hidetray.table[s] = backgr()
    end
    hidetray.tray = systray(args.revers)
    return hidetray.table
end

function hidetray.mt:__call(...)
    return newtable(...)
end

return setmetatable(hidetray, hidetray.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
