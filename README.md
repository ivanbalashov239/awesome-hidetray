
tray = systray({revers = true})
text = wibox.widget.textbox("0")
systray:attachtext(text)
systray:show(1)
systray.hidetimer:start()

for s = 1, screen.count() do
    systray:attach({ wibox = mywibox[s], screen = s})

    right_layout:add(text)
    right_layout:add(tray[s])
