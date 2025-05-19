require("config.lazy")

require('tokyonight').setup({
  transparent = true,
  styles = {
    sidebars = "transparent",
    floats = "transparent",
  },
})

vim.cmd [[colorscheme tokyonight]]
