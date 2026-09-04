--#######################
--## GLOBAL VARIABLES ###
--#######################

---@module 'hl'

local mainMod = "SUPER"
local terminal = "kitty --single-instance"
local fileManager = "thunar"
local menu = "wofi --show drun"

return {
	mainMod = mainMod,
	terminal = terminal,
	fileManager = fileManager,
	menu = menu,
}
