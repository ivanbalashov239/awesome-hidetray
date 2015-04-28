---------------------------------------------------------------------------
-- @author Ivan Balashov
-- @original author Uli Schlachter
-- @copyright 2010 Uli Schlachter
-- @copyright 2015 Ivan Balashov
---------------------------------------------------------------------------

local wbase = require("wibox.widget.base")
local naughty = require("naughty")
local wconst = require("wibox.layout.constraint")
local lbase = require("wibox.layout.base")
local awfwibox = require("awful.wibox")
local beautiful = require("beautiful")
local capi = { awesome = awesome }
local setmetatable = setmetatable
local error = error
local abs = math.abs

--- wibox.widget.systray
local systray = { mt = {} }

local horizontal = true
local base_size = nil
local reverse = false
systray.width = 0
systray.number = 0
systray.table = {}

function systray:plus(number)
    systray.number = systray.number + number
    if systray.textbox then
        systray.textbox:set_text(systray.number)
    end
end
function systray:attachtext(textbox)
    systray.textbox = textbox
end

function systray:draw(wibox, cr, width, height)
    if height ~= 18 then
        systray:plus((width - systray.width)/height)
        systray.width = width
    end
    local x, y, _, _ = lbase.rect_to_device_geometry(cr, 0, 0, width, height)
    local num_entries = capi.awesome.systray()
    local bg = beautiful.bg_systray or beautiful.bg_normal or "#000000"

    -- Figure out if the cairo context is rotated
    local dir_x, dir_y = cr:user_to_device_distance(1, 0)
    local is_rotated = abs(dir_x) < abs(dir_y)

    local in_dir, ortho, base
    if horizontal then
        in_dir, ortho = width, height
        is_rotated = not is_rotated
    else
        ortho, in_dir = width, height
    end
    if ortho * num_entries <= in_dir then
        base = ortho
    else
        base = in_dir / num_entries
    end
    capi.awesome.systray(wibox.drawin, x, y, base, is_rotated, bg, reverse)
end

function systray:fit(width, height)
    local num_entries = capi.awesome.systray()
    local base = base_size
    if base == nil then
        if width < height then
            base = width
        else
            base = height
        end
    end
    if horizontal then
        return base * num_entries, base
    end
    return base, base * num_entries
end

function systray:new(revers)
    local ret = wbase.make_widget()

    ret.fit = systray.fit
    ret.draw = systray.draw
    ret.set_base_size = function(_, size) base_size = size end
    ret.set_horizontal = function(_, horiz) horizontal = horiz end
    ret.set_reverse = function(revers) reverse = revers end

    if revers then
        ret:set_reverse(true)
    end

    capi.awesome.connect_signal("systray::update", function()
        ret:emit_signal("widget::updated")
    end)

    return ret
end

function systray:show(s)
    systray.hidetimer:stop()
    for i,k in pairs(systray.table) do
        if not i == s then
            systray:hide(i)
        else
            systray.traybufer:set_widget(nil)
            systray.table[s]:set_widget(systray.tray)
        end
    end
end
function systray:hide(s)
    systray.traybufer:set_widget(systray.tray)
    systray.table[s]:reset()
end

function systray:attach(args)
    local args = args or {}
    local wib = args.wibox
    local revers = args.revers
    local s = args.screen or 1
    if wib then
        wib:connect_signal('mouse::enter', function () 
            systray:show(s)
        end)
        wib:connect_signal('mouse::leave', function ()
            if (mouse.object_under_pointer() and mouse.object_under_pointer().name ) or mouse.screen ~= s then 
                systray:hide(s)
            else
                systray.hidetimer:start()
            end
        end)
    end
end

local function newtable(args)
    local args = args or {}
    local number = args.number or screen.count()
    local backgr = args.background or wconst
    local gettimerscreen = args.focusscreen or function() return mouse.screen end
    systray.traybufer = args.traybufer or awfwibox({ x = -55, y = -55})
    systray.hidetimer = timer({ timeout = args.timeout or 5 })
    systray.hidetimer:connect_signal("timeout", function ()
        for s = 1, number do
            systray:hide(s)
        end
        systray.hidetimer:stop()
    end)
    awesome.connect_signal("systray::update", function()
        systray:show(gettimerscreen())
        systray.hidetimer:start()
    end)

    for s =  1, number do
        systray.table[s] = backgr()
    end
    systray.tray = systray:new(args.revers)
    return systray.table
end

function systray.mt:__call(...)
    return newtable(...)
end

return setmetatable(systray, systray.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
