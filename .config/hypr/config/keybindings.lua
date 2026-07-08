--##################
--## KEYBINDINGS ###
--##################

---@module 'hl'

local mainMod = "SUPER"

-- Basic operations
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- Launcher
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call rect getToggle"))

-- Dashboard
hl.bind(
	mainMod .. " + D",
	hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call dashboard getToggle")
)

-- Lock
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call lock lock"))

-- Panels
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call calendar getToggle"))

hl.bind(
	mainMod .. " + B",
	hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call bluetooth getToggle")
)

hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call cpu getToggle"))

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call ram getToggle"))

hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call weather getToggle"))

hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call keybind getToggle"))

hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call wifi getToggle"))

hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call mixer getToggle"))

hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("qs ipc --path ~/.config/quickshell/cartoon-shell/ call battery getToggle"))
-- Focus movement
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspace switching
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end

-- Move window to workspace
for i = 1, 9 do
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Window manipulation with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 2.0 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)

-- Brightness control
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd([[
        sh -c '
        brightnessctl -e4 -n2 set 5%+
        qs ipc --path ~/.config/quickshell/cartoon-shell \
            call brightness set \
            "$(awk "BEGIN {print $(brightnessctl g)/$(brightnessctl m)}")"
        '
    ]]),
	{ locked = true, repeating = true }
)

hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd([[
        sh -c '
        brightnessctl -e4 -n2 set 5%-
        qs ipc --path ~/.config/quickshell/cartoon-shell \
            call brightness set \
            "$(awk "BEGIN {print $(brightnessctl g)/$(brightnessctl m)}")"
        '
    ]]),
	{ locked = true, repeating = true }
) -- Media control
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Screenshots
hl.bind(
	"PRINT",
	hl.dsp.exec_cmd(
		'FILE=~/Pictures/screenshot_$(date +\'%Y-%m-%d_%H-%M-%S\').png && grim "$FILE" && wl-copy --type image/png < "$FILE" && notify-send "📸 Screenshot" "Đã chụp toàn màn hình\\nẢnh đã lưu & copy"'
	)
)
hl.bind(
	mainMod .. " + PRINT",
	hl.dsp.exec_cmd(
		'FILE=~/Pictures/screenshot_$(date +\'%Y-%m-%d_%H-%M-%S\').png && grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE" && notify-send "📸 Screenshot" "Đã chụp vùng chọn\\nẢnh đã lưu & copy"'
	)
)
