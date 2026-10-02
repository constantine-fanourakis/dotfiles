-- ============================================================
--  Hyprland config  (Lua API, Hyprland 0.56+)
--  Machine: openSUSE Tumbleweed laptop (eDP-1 + external HDMI)
--  Docs: https://wiki.hypr.land/Configuring/Start/
-- ============================================================

-- Catppuccin Mocha, official port: https://github.com/catppuccin/hyprland
-- Theme module lives at ~/.config/hypr/themes/catppuccin-mocha.lua
local colors = require('themes.catppuccin-mocha')

------------------
---- MONITORS ----
------------------
-- "auto" handles laptop panel + hotplugged external fine.
-- To pin them explicitly, comment this out and use the examples below.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- The external panel is pinned rather than left on "preferred": the T490's
-- HDMI 1.4b port caps 3840x2160 at 30 Hz, and scale 1.5 forces XWayland clients
-- to render at 1440p and be upscaled. Driving 1440p natively at 60 Hz gives the
-- same logical desktop size, pixel-exact XWayland, and double the refresh.
hl.monitor({
    output   = "HDMI-A-2",
    mode     = "2560x1440@59.95",
    position = "auto",
    scale    = 1,
})

-- Explicit dual-monitor example (edit + uncomment if auto placement is wrong):
-- hl.monitor({ output = "eDP-1",     mode = "preferred", position = "0x1080", scale = 1 })
-- hl.monitor({ output = "HDMI-A-2",  mode = "preferred", position = "0x0",    scale = 1 })

-- Clamshell handling.
-- Lid state comes from systemd-logind's LidClosed property: the vendor-neutral
-- API, rather than an ACPI path like /proc/acpi/button/lid/LID/state whose
-- directory name varies by manufacturer.
local function lidIsClosed()
    local pipe = io.popen("busctl get-property org.freedesktop.login1 " ..
                          "/org/freedesktop/login1 org.freedesktop.login1.Manager " ..
                          "LidClosed 2>/dev/null")
    if not pipe then return false end
    local out = pipe:read("*a") or ""
    pipe:close()
    return out:match("true") ~= nil
end

-- Documented API: https://wiki.hypr.land/configuring/core/monitors/
local function setInternalPanel(enabled)
    -- `disabled` MUST be set explicitly in both directions: monitor rule fields
    -- persist, so omitting `disabled = false` here leaves an earlier
    -- `disabled = true` in place and the panel never comes back on lid-open.
    if enabled then
        -- scale = 1 (not "auto"): auto picks 1.5 on this 14" 1080p panel, which
        -- renders a logical 1280x720 and oversized UI. 1 gives a true 1920x1080.
        hl.monitor({ output = "eDP-1", disabled = false,
                     mode = "preferred", position = "auto", scale = 1 })
    else
        hl.monitor({ output = "eDP-1", disabled = true })
    end
end

-- Evaluated at parse time, so it applies on both initial load and `hyprctl reload`.
-- Hyprland does not disable the internal panel on its own, so without this a
-- session started lid-closed lights up eDP-1 as an invisible phantom display.
-- Always emit an explicit eDP-1 rule, in both lid states: when open, this is
-- what pins scale = 1: leaving it to the catch-all above would apply "auto".
setInternalPanel(not lidIsClosed())

-- Re-assert lid state when an external display is hotplugged. Docking while the
-- lid is shut fires no lid transition, so without this the panel could stay on
-- as a phantom display. Guarded on name so re-enabling eDP-1 cannot re-trigger
-- this handler on itself.
hl.on("monitor.added", function(m)
    if m and m.name ~= "eDP-1" then
        setInternalPanel(not lidIsClosed())
    end
end)


---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "ghostty"
local fileManager = "dolphin"
local menu        = "fuzzel"
local browser     = "xdg-open https://"


-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    -- Hand the session env to systemd/D-Bus, THEN activate the session target.
    -- These MUST be chained in one shell: hl.exec_cmd is async, and the shipped
    -- units carry ConditionEnvironment=WAYLAND_DISPLAY -- starting the target
    -- before the env import lands would silently skip every one of them.
    --
    -- The target pulls in the units openSUSE ships (hyprpaper, hypridle,
    -- hyprpolkitagent, waybar) via WantedBy=graphical-session.target. dunst is
    -- Type=dbus and activates on the first notification, so it needs no entry.
    -- systemd then provides Restart=on-failure, ordering and clean shutdown,
    -- which exec_cmd cannot. Manage them with: systemctl --user status waybar
    hl.exec_cmd("sh -c 'dbus-update-activation-environment --systemd "
             .. "WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE XDG_SESSION_TYPE "
             .. "&& systemctl --user start hyprland-session.target'")
end)

-- Stop the session target when Hyprland exits. Without this the units keep
-- running after the compositor is gone, lose their Wayland connection, and
-- burn through their whole restart budget in about a second -- landing in
-- start-limit-hit BEFORE the next session exists, so nothing autostarts.
hl.on("hyprland.shutdown", function()
    -- Stops graphical-session.target, not hyprland-session.target: the services
    -- are PartOf the former and keep it alive as reverse dependencies, so
    -- stopping hyprland-session.target does not cascade to them.
    hl.exec_cmd("systemctl --user stop graphical-session.target")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- Set explicitly so XWayland apps (Steam, games) match Wayland-native ones.
-- Without it XWayland falls back to XCursor's legacy bitmaps: there is no
-- /usr/share/icons/default/index.theme on this system to catch it.
-- hl.env persists across `hyprctl reload`: deleting a line does not unset the
-- variable for newly spawned processes; only a compositor restart clears it.
hl.env("XCURSOR_THEME",   "breeze_cursors")
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt/KDE apps (dolphin etc.) render natively on Wayland, fall back to X11
hl.env("QT_QPA_PLATFORM",                     "wayland;xcb")

-- Makes Qt/KDE apps (dolphin, systemsettings, ...) use the KDE platform theme,
-- so they read ~/.config/kdeglobals for colors, widget style and icons.
-- Provided by plasma6-integration-plugin. Without this they fall back to plain
-- Fusion styling and silently ignore your Breeze Dark settings.
hl.env("QT_QPA_PLATFORMTHEME",                "kde")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",         "1")
hl.env("MOZ_ENABLE_WAYLAND",                  "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT",        "auto")


-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in  = 0,
        gaps_out = 0,

        border_size = 2,

        col = {
            -- Deliberately muted: flat greys from the Catppuccin palette rather
            -- than a saturated gradient. overlay0 reads as focused without
            -- drawing the eye; surface0 sits just above the background.
            active_border   = colors.overlay0,
            inactive_border = colors.surface0,
        },

        resize_on_border = true,   -- drag borders/gaps to resize
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 0,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = { enabled = true },

    dwindle = {
        preserve_split = true,
    },

    master = { new_status = "master" },

    cursor = {
        -- Hide the pointer as soon as you start typing; it reappears on any
        -- mouse movement. Stops it sitting in the middle of text you're editing.
        hide_on_key_press = true,
    },

    misc = {
        force_default_wallpaper = 0,      -- no anime mascot; hyprpaper handles it
        disable_hyprland_logo   = true,

        -- Both default to false: without these, once hypridle blanks the screen
        -- via dpms, input will NOT wake it and the machine looks dead.
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,

        -- If a lock screen crashes or is killed, the compositor stays in a
        -- "lockdead" state. This lets a freshly launched hyprlock take over
        -- that session lock instead of leaving you stuck.
        allow_session_lock_restore = true,
    },
})

-- Animation curves
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })


---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
            tap_to_click         = true,
            drag_lock            = true,
        },
    },
})

-- 3-finger horizontal swipe changes workspace
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Launching
hl.bind(mainMod .. " + T",         hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("/home/kalidasa/.config/hypr/scripts/window-switcher.sh"))
hl.bind(mainMod .. " + ESCAPE",    hl.dsp.exec_cmd("hyprlock"))

-- Window management
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + B",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd(
    "sh -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'"))
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + BACKSLASH", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())

-- Move focus (arrows + vim keys)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))
hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + L",     hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down"  }))

-- Move window within layout
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left"  }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up"    }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down"  }))
hl.bind(mainMod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "left"  }))
hl.bind(mainMod .. " + SHIFT + L",     hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up"    }))
hl.bind(mainMod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down"  }))

-- Workspaces
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Alt+Tab cycles WINDOWS (the conventional meaning); Super+Tab jumps to the
-- most recently used WORKSPACE. Selectors per https://wiki.hypr.land/ --
-- workspace "previous" is global MRU, "previous_per_monitor" is per-display.
-- Alt+Tab: native MRU toggle -- bounce to the last-focused window. This is the
-- dispatcher added by hyprwm/Hyprland#1290. bring_to_top() is paired with it
-- because focus alone does not raise a stacked/floating window, which is the
-- usual reason a bare cyclenext bind "does nothing" visually.
hl.bind("ALT + TAB", function()
    hl.dispatch(hl.dsp.focus({ last = true }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- Alt+Shift+Tab: step through every window in order, for when you want to walk
-- the list rather than bounce between two.
hl.bind("ALT + SHIFT + TAB", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))

-- Scratchpad
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse drag move/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots (grim + slurp); both copy to clipboard AND save to ~/Pictures/Screenshots
hl.bind("PRINT",           hl.dsp.exec_cmd("/home/kalidasa/.config/hypr/scripts/screenshot.sh output"))
hl.bind("SHIFT + PRINT",   hl.dsp.exec_cmd("/home/kalidasa/.config/hypr/scripts/screenshot.sh region"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("/home/kalidasa/.config/hypr/scripts/screenshot.sh region"))

-- Volume / brightness / media (work while screen is locked)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true },
    no_focus = true,
})

-- Float common dialogs
hl.window_rule({
    -- Steam client windows (library, friends, settings, game pages). Games
    -- launched from Steam carry their own class and are unaffected.
    name  = "float-steam",
    match = { class = "^steam$" },
    float = true,
})

hl.window_rule({
    name  = "float-dialogs",
    match = { class = "^(pavucontrol|nm-connection-editor|blueman-manager|org.kde.polkit-kde-authentication-agent-1)$" },
    float = true,
})


------------------
---- LID SWITCH ---
------------------
-- Runtime transitions. Helpers + the parse-time check live in MONITORS above.
-- These call hl.monitor() directly. `hyprctl keyword` is rejected by the Lua
-- parser: "keyword can't work with non-legacy parsers. Use eval."
-- Switch name from `hyprctl devices` as the wiki specifies -> "Lid Switch".
-- Syntax per https://wiki.hypr.land/configuring/core/binds/switches/
-- 'locked = true' so they still fire while the screen is locked.
hl.bind("switch:on:Lid Switch",  function() setInternalPanel(false) end, { locked = true })
hl.bind("switch:off:Lid Switch", function() setInternalPanel(true)  end, { locked = true })
