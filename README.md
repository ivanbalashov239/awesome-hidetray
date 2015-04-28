# Hide systray
# You can show tray when your panel under the mouse

	tray = hidetray({revers = true})
	hidetray:show(1)
	hidetray.hidetimer:start()
	for s = 1, screen.count() do
		---
    		hidetray:attach({ wibox = mywibox[s], screen = s})
    		right_layout:add(tray[s])
	end

# And you can make shortcut to show tray for timeout like after systray::update
	
	
    awful.key({ modkey,           }, "/",      function () 
	    hidetray:show(mouse.screen) 
	    hidetray.hidetimer:start()
    end),

# Or any other rule or something

##
