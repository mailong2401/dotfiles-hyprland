-- #######################################################################################
-- HYPRLAND CONFIG
-- #######################################################################################
require("config.monitors")
require("config.variables")
require("config.programs")
require("config.environment")
require("config.appearance")
require("config.animations")
require("config.input")
require("config.keybindings")
require("config.autostart")

-- Layout tùy chỉnh do người dùng chọn trong Dashboard (Quickshell) sinh ra tại
-- ~/.config/hypr/custom/layout/split-method.lua. File này KHÔNG tồn tại cho tới
-- khi người dùng bấm "Áp dụng ngay" lần đầu trong Dashboard, nên phải bọc pcall —
-- nếu không, thiếu file sẽ làm require() lỗi và sập toàn bộ config Hyprland.
-- Đặt SAU require("config.appearance") để layout tùy chỉnh override layout mặc định.
local customLayoutOk, customLayoutErr = pcall(require, "custom.layout.split-method")
if not customLayoutOk then
	-- Chưa có layout tùy chỉnh nào được áp dụng, hoặc file lỗi cú pháp — bỏ qua,
	-- dùng layout mặc định trong config/appearance.lua.
end
