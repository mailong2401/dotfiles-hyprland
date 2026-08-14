--#################
--## ANIMATIONS ###
--#################

---@module 'hl'

hl.config({
	animations = {
		enabled = true,
	},
})

-- Bézier curves
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })
hl.curve("silk", { type = "bezier", points = { { 0.45, 0 }, { 0.15, 1 } } })

-- Springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

-- Animation configurations
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Nạp file hiệu ứng workspace tùy chọn do Effects.qml tạo ra
-- QUAN TRỌNG: phải xoá cache của require() trước mỗi lần nạp, nếu không
-- Lua sẽ chỉ chạy file này ĐÚNG 1 LẦN (ở lần reload đầu tiên) rồi cache lại,
-- khiến các lần đổi hiệu ứng sau đó (ghi đè file + hyprctl reload) không có
-- tác dụng gì vì require() không đọc lại file mới nữa.
package.loaded["custom.effects.workspace-animation"] = nil
local ok, err = pcall(require, "custom.effects.workspace-animation")
if not ok then
	print("[animations.lua] Lỗi khi nạp workspace-animation.lua: " .. tostring(err))
end