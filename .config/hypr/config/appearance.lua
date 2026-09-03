--####################
--## LOOK AND FEEL ###
--####################

---@module 'hl'

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,
		border_size = 2,

		col = {
			active_border = "rgba(44464f77)",
			inactive_border = "rgba(1a1b2033)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},
})

hl.config({
	dwindle = {
		preserve_split = true,
	},
	master = {
		new_status = "master",
	},
	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = true,
	},
})

-- Kitty tự vẽ độ trong suốt nền của riêng nó (background_opacity trong kitty.conf).
-- Không tắt rule này thì Hyprland sẽ tự blur nền phía sau kitty mỗi khi opacity < 1,
-- chồng thêm hiệu ứng blur không mong muốn lên trên độ trong suốt đã chỉnh.
hl.window_rule({
	name = "kitty-noblur",
	match = { class = "kitty" },
	no_blur = true,
})
