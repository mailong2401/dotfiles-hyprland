--##################
--## KEYBINDINGS ###
--##################
--
-- This file no longer declares each hl.bind() by hand.
-- The full shortcut list lives in:
--   ~/.config/quickshell/cartoon-shell/data/keybinds.json
-- That same JSON file is what the two QML panels (Shortcuts.qml and
-- KeyBindDisplay.qml) read to display shortcuts and let the user edit
-- them directly in the UI.
--
-- To add a new action type (e.g. a new hl.dsp.* function), add it to
-- the `dispatch` table in keybind_loader.lua.

---@module 'hl'

-- Explicitly add this file's own directory (~/.config/hypr/config/) to
-- Lua's module search path before requiring the loader. This avoids
-- depending on whatever working directory `hl` happens to run from —
-- a plain `require("keybind_loader")` can silently fail to find the
-- module if hl's cwd isn't this config directory.
local configDir = os.getenv("HOME") .. "/.config/hypr/config/"
package.path = configDir .. "?.lua;" .. package.path

require("keybind_loader").load()
