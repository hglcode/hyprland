-- ~/.config/hypr/config.lua
-- Hyprland 0.56.2 Lua Configuration
-- Converted from hyprland.conf

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "2560x1440@165",
    position = "auto",
    scale    = 1,
    bitdepth = 10,
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "alacritty"
local fileManager = "pcmanfm-qt"
local menu        = "hyprlauncher"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/backlight.sh on")
    hl.exec_cmd("hyprctl setcursor macOS-White 19")
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("systemctl --user restart app-org.fcitx.Fcitx5@autostart.service")
    hl.exec_cmd("systemctl --user restart hyprpolkitagent.service")
    hl.exec_cmd("systemctl --user restart hypridle.service")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_THEME", "macOS-White")
hl.env("XCURSOR_SIZE", "19")
hl.env("HYPRCURSOR_THEME", "macOS-White")
hl.env("HYPRCURSOR_SIZE", "19")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 0,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 5,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.88,

        shadow = {
            enabled      = false,
            range        = 3,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = false,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = false,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },

    quirks = {
        prefer_hdr = 1,
    },

    cursor = {
        no_hardware_cursors = true,
    },

    scrolling = {
        column_width = 5.0,
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 0,

        sensitivity   = -1.0,
        accel_profile = "adaptive",
        scroll_factor = 3,

        numlock_by_default = true,
        repeat_delay       = 150,
        repeat_rate        = 60,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"
local home    = os.getenv("HOME")

-- Applications
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("x-www-browser"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("subl"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))

-- Window management
hl.bind(mainMod .. " + X", hl.dsp.window.close())
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/toggle_floating.sh"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + W", hl.dsp.layout("togglesplit"))

-- Maximize toggle
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/toggle_maximize.sh"))

-- Workspace navigation
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "e+1" }))

-- Alt+Tab / Alt+Grave: switch clients
hl.bind("ALT + grave", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/switch_client.sh group"))
hl.bind("ALT + Tab",   hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/switch_client.sh workspace"))

-- Screenshot
hl.bind("ALT + A", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces & move windows with mainMod + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,          hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,  hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind("CTRL + SPACE",            hl.dsp.workspace.toggle_special("magic"))

-- Scroll through workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move windows with mainMod + ALT/CTRL + arrows
hl.bind(mainMod .. " + ALT + left",   hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + ALT + right",  hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + ALT + up",     hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + ALT + down",   hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.move({ direction = "down" }))

-- Mouse bindings (move/resize with drag)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("mouse:274",               hl.dsp.window.drag(),   { mouse = true })

-- Multimedia keys: volume and brightness (locked + repeating)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Media player controls (locked, non-repeating)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})
