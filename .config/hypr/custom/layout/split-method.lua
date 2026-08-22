hl.config({
	general = {
		layout = "master",
	},
	master = {
		new_status = "slave",
		orientation = "left",
		mfact = 0.55,
	},
})

-- Bo tròn cửa sổ thật, đồng bộ với previewRadius trên card
hl.config({
	decoration = {
		rounding = 7,
		rounding_power = 2.5,
		active_opacity = 1.0,
		inactive_opacity = 0.94,
		shadow = { enabled = true, range = 18, render_power = 3, color = "rgba(00000055)" },
	},
})

-- Bộ hiệu ứng cho cửa sổ THẬT, đồng bộ cảm giác nảy như trên UI Dashboard.
-- Spring cho hiệu ứng nảy nhẹ khi mở / kéo-thả / snap vào layout:
hl.curve("dashboardBounce", { type = "spring", mass = 1, stiffness = 170, dampening = 14 })
-- Bezier mượt cho các chuyển động không cần nảy (đóng, mờ dần, đổi workspace):
hl.curve("dashboardSmooth", { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })

hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, spring = "dashboardBounce", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 4, bezier = "dashboardSmooth", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, spring = "dashboardBounce" })
hl.animation({ leaf = "border",      enabled = true, speed = 6, bezier = "dashboardSmooth" })
hl.animation({ leaf = "fade",        enabled = true, speed = 5, bezier = "dashboardSmooth" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, bezier = "dashboardSmooth", style = "slide" })
