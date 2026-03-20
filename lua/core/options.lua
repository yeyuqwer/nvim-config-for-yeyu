-- Centralized editor options.
local opt = vim.opt

opt.encoding = "UTF-8"
opt.fileencoding = "utf-8"

-- Keep context while moving.
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.signcolumn = "yes"

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftround = true
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

opt.cmdheight = 2
opt.autoread = true
opt.wrap = false
opt.whichwrap = "<,>,[,]"
opt.hidden = true
opt.mouse = "a"
opt.list = true
opt.listchars = {
  tab = "> ",
  trail = " ",
  nbsp = "+",
}

opt.backup = false
opt.writebackup = false
opt.swapfile = false

opt.updatetime = 300
opt.timeoutlen = 500

opt.splitbelow = true
opt.splitright = true

opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
opt.termguicolors = true
opt.wildmenu = true
opt.shortmess:append("c")
opt.pumheight = 10
opt.showtabline = 2
opt.showmode = false

-- Disable cursor blinking.
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
