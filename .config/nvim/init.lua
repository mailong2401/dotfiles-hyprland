require("config.lazy")

require("tokyonight").setup({
  transparent = true,
  styles = {
    sidebars = "transparent",
    floats = "transparent",
  },
})

vim.cmd([[colorscheme tokyonight]])

require("toggleterm").setup({
  size = 20,
  open_mapping = [[<c-\>]],
  direction = "float", -- hoặc 'vertical' hoặc 'float'
  shade_terminals = true,
  start_in_insert = true,
  insert_mappings = true,
})

vim.keymap.set("n", "<leader>rj", function()
  local filename = vim.fn.expand("%:t")
  local classname = vim.fn.expand("%:t:r")
  local cmd = "javac " .. filename .. " && java " .. classname .. " && read"
  require("toggleterm.terminal").Terminal:new({ cmd = cmd, direction = "float" }):toggle()
end, { noremap = true, silent = true, desc = "Run Java file" })
