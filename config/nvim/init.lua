-- GoodTerminal Neovim Configuration - Seamless tmux integration

-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings
vim.opt.number = true                   -- Show line numbers
vim.opt.relativenumber = true           -- Show relative line numbers
vim.opt.mouse = 'a'                     -- Enable mouse support
vim.opt.ignorecase = true               -- Case insensitive search
vim.opt.smartcase = true                -- But case sensitive when uppercase present
vim.opt.hlsearch = true                 -- Highlight search results
vim.opt.incsearch = true                -- Show matches as you type
vim.opt.tabstop = 2                     -- 2 spaces for tabs
vim.opt.shiftwidth = 2                  -- 2 spaces for indentation
vim.opt.expandtab = true                -- Use spaces instead of tabs
vim.opt.cursorline = true               -- Highlight current line
vim.opt.termguicolors = true            -- True color support
vim.opt.clipboard = 'unnamedplus'       -- Use system clipboard
vim.opt.scrolloff = 8                   -- Start scrolling 8 lines before edge
vim.opt.updatetime = 300                -- Faster completion
vim.opt.timeoutlen = 500                -- Faster key sequence completion
vim.opt.signcolumn = "yes"              -- Always show sign column
vim.opt.wrap = false                    -- Don't wrap lines
vim.opt.swapfile = false               -- Don't create swap files
vim.opt.backup = false                 -- Don't create backup files
vim.opt.undofile = true                -- Enable persistent undo
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.splitbelow = true              -- Split below
vim.opt.splitright = true              -- Split to the right

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Plugin setup with Lazy.nvim
require("lazy").setup({
  -- Seamless tmux/vim navigation
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
  },
  
  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'onedark',
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
        }
      })
    end,
  },
  
  -- File explorer
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup({
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
        actions = {
          change_dir = {
            enable = true,
            global = false,
          },
        },
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')
          
          local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end
          
          -- Default mappings
          api.config.mappings.default_on_attach(bufnr)
          
          -- Custom mappings
          vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
          vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
          vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts('Up'))
        end,
      })
    end,
  },
  
  -- Telescope for fuzzy finding
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {
          path_display = { "truncate" },
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })
    end,
  },
  
  -- Colorscheme
  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('onedark').setup({
        style = 'dark',
        transparent = false,
        term_colors = true,
      })
      require('onedark').load()
    end,
  },
  
  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'pyright', 'tsserver', 'bashls' },
      })
      
      local lspconfig = require('lspconfig')
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      
      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' },
            },
          },
        },
      })
      
      -- Python
      lspconfig.pyright.setup({ capabilities = capabilities })
      
      -- JavaScript/TypeScript
      lspconfig.tsserver.setup({ capabilities = capabilities })
      
      -- Bash
      lspconfig.bashls.setup({ capabilities = capabilities })
    end,
  },
  
  -- Auto-completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },
  
  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'lua', 'vim', 'vimdoc', 'python', 'javascript', 'typescript', 'bash' },
        auto_install = true,
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
  
  -- Comment plugin
  {
    'numToStr/Comment.nvim',
    opts = {},
    lazy = false,
  },
  
  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  
  -- Git signs
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        current_line_blame = false,
      })
    end,
  },
  
  -- Lazygit integration
  {
    'kdheepak/lazygit.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
  
  -- AI autocompletion with Windsurf
  {
    'Exafunction/windsurf.vim',
    lazy = false,
    -- Skip during headless installation
    cond = function()
      return vim.env.SKIP_WINDSURF_AUTH ~= "1"
    end,
    config = function()
      -- Disable default bindings to avoid conflicts
      vim.g.windsurf_disable_keybindings = 1
      
      -- Custom keybindings
      vim.keymap.set('i', '<Tab>', function()
        return vim.fn['windsurf#Accept']()
      end, { expr = true, silent = true })
      
      vim.keymap.set('i', '<C-e>', function()
        return vim.fn['windsurf#Dismiss']()
      end, { expr = true, silent = true })
      
      vim.keymap.set('i', '<M-]>', function()
        return vim.fn['windsurf#Next']()
      end, { expr = true, silent = true })
      
      vim.keymap.set('i', '<M-[>', function()
        return vim.fn['windsurf#Previous']()
      end, { expr = true, silent = true })
    end,
  },
})

-- Keybindings
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- File explorer
map('n', '<leader>e', ':NvimTreeToggle<CR>', opts)

-- Telescope
map('n', '<leader>ff', ':Telescope find_files<CR>', opts)
map('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
map('n', '<leader>fb', ':Telescope buffers<CR>', opts)
map('n', '<leader>fh', ':Telescope help_tags<CR>', opts)

-- Split navigation - works with vim-tmux-navigator
map('n', '<C-h>', '<C-w>h', opts)
map('n', '<C-j>', '<C-w>j', opts)
map('n', '<C-k>', '<C-w>k', opts)
map('n', '<C-l>', '<C-w>l', opts)

-- Split creation
map('n', '<leader>v', ':vsplit<CR>', opts)
map('n', '<leader>s', ':split<CR>', opts)

-- Window resizing
map('n', '<C-Up>', ':resize -2<CR>', opts)
map('n', '<C-Down>', ':resize +2<CR>', opts)
map('n', '<C-Left>', ':vertical resize -2<CR>', opts)
map('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- Better window navigation
map('n', '<leader>w', '<C-w>w', opts)
map('n', '<leader>q', ':q<CR>', opts)
map('n', '<leader>x', ':x<CR>', opts)

-- Buffer navigation
map('n', '<leader>bn', ':bnext<CR>', opts)
map('n', '<leader>bp', ':bprevious<CR>', opts)
map('n', '<leader>bd', ':bdelete<CR>', opts)

-- Clear search highlighting
map('n', '<leader>nh', ':nohl<CR>', opts)

-- Git
map('n', '<leader>gg', ':LazyGit<CR>', opts)
map('n', '<leader>gc', ':LazyGitConfig<CR>', opts)

-- LSP mappings
map('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
map('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
map('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
map('n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
map('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
map('n', '<leader>f', '<Cmd>lua vim.lsp.buf.format()<CR>', opts)