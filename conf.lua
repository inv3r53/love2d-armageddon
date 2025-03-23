function love.conf(t)
    t.title = "Armageddon"        -- The title of the window
    t.version = "11.4"            -- The LÖVE version this game was made for
    t.window.width = 800          -- Game's screen width
    t.window.height = 600         -- Game's screen height
    t.window.vsync = 1            -- Enable vertical sync
    t.window.resizable = false    -- Let the window be user-resizable

    -- For debugging
    t.console = true              -- Enable console output for debugging
end