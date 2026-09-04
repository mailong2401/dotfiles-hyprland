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
-- Giảm tốc mượt, dùng cho lúc ĐÓNG/mờ dần cửa sổ — thay cho "linear" thô cứng trước đây
hl.curve("smoothDecel", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })

-- Springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })
-- Spring nảy rõ hơn "easy" (damping ratio ~0.54, có overshoot nhìn thấy được),
-- dùng riêng cho windows/windowsIn/windowsMove để cửa sổ THẬT có cảm giác nảy
-- khi mở / kéo-thả / snap vào layout, thay vì mượt gần như không nảy như "easy".
hl.curve("bouncy", { type = "spring", mass = 1, stiffness = 170, dampening = 14 })

-- Animation configurations
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "bouncy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "bouncy", style = "popin 87%" })
-- ĐÓNG cửa sổ: trước đây bezier="linear" (tuyến tính, cảm giác cứng/robot).
-- Đổi sang "smoothDecel" + tăng nhẹ speed để thu nhỏ êm ái, không giật.
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.2, bezier = "smoothDecel", style = "popin 87%" })
-- Trước đây KHÔNG khai báo windowsMove -> tự kế thừa "windows" cũ (chưa nảy).
-- Khai báo riêng để kéo/thả/snap cửa sổ có độ nảy nhẹ, rõ ràng khi chạm layout mới.
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3.6, spring = "bouncy" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "quick" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.8, bezier = "smoothDecel" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
-- Trước đây KHÔNG khai báo workspaces -> kế thừa "global" (default, không style
-- slide) nên chuyển workspace khá cụt lủn. Thêm slide mượt cho cảm giác trượt êm.
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "easeOutQuint", style = "slidevert" })

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