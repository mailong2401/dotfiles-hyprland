--################
--## AUTOSTART ###
--################

---@module 'hl'

hl.on("hyprland.start", function()
	hl.exec_cmd("qs -p ~/.config/quickshell/cartoon-shell")
	hl.exec_once("fcitx5 -d --replace")
end)
