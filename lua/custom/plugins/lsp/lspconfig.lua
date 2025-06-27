return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    { 'antosha417/nvim-lsp-file-operations', config = true },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require 'lspconfig'

    -- load autocompletion source (nvim-cmp)
    local cmp_nvim_lsp = require 'cmp_nvim_lsp'

    local keymap = vim.keymap

    local opts = { noremap = true, silent = true }
    local on_attach = function(client, bufnr)
      opts.buffer = bufnr

      -- set keybinds
      opts.desc = 'Show LSP reference'
      keymap.set('n', 'gR', '<cmd>Telescope lsp_references<CR>', opts) -- Show LSP references

      opts.desc = 'Go to declaration'
      keymap.set('n', 'gD', vim.lsp.buf.declaration, opts) -- Go to declaration

      opts.desc = 'Show LSP definition'
      keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', opts) -- Show LSP definitions

      opts.desc = 'Show LSP implementations'
      keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', opts) -- LSP implementations

      opts.desc = 'See available code actions'
      keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts) -- see avaialble code actions

      opts.desc = 'Smart rename'
      keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts) -- smart rename; not sure what this is?

      opts.desc = 'Show buffer diagnostics'
      keymap.set('n', '<leader>D', '<cmd>Telescope diagnostics bufnr=0<CR>', opts) -- show diagnostics for file

      opts.desc = 'Show line diagnostics'
      keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts) -- show diagnostics for line

      opts.desc = 'Go to previous diagnostic'
      keymap.set('n', '[d', vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

      opts.desc = 'Go to next diagnostic'
      keymap.set('n', ']d', vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

      opts.desc = 'Show documentation for content under cursor'
      keymap.set('n', 'K', vim.lsp.buf.hover, opts) -- show documentation for content under cursor

      opts.desc = 'Restart LSP'
      keymap.set('n', '<leader>rs', ':LspRestart<CR>', opts) -- restart lsp, if necessary
    end

    -- used to enable autocompletion (needs to be assigned to ever lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- change the Diagnostic symbols in the gutter
    vim.diagnostic.config {
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = ' ',
          [vim.diagnostic.severity.WARN] = ' ',
          [vim.diagnostic.severity.HINT] = ' ',
          [vim.diagnostic.severity.INFO] = ' ',
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = '',
          [vim.diagnostic.severity.WARN] = '',
          [vim.diagnostic.severity.HINT] = '',
          [vim.diagnostic.severity.INFO] = '',
        },
      },
    }
    -- [ayun]:      Apparently the below had been deprecated at some point?
    -- =====================================================================
    -- local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
    -- for type, icon in pairs(signs) do
    --   local hl = 'DiagnosticSign' .. type
    --   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    -- end
    -- =====================================================================

    -- configure lua server
    lspconfig['lua_ls'].setup {
      capabilities = capabilities,
      on_attach = on_attach,
    }

    -- conrfigure python server
    lspconfig['pylsp'].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        pylsp = {
          plugins = {
            -- linters and whatnot
            pycodestyle = {
              enabled = true,
              ignore = { 'E305' },
              maxLineLength = 150,
            },
            pyflakes = { disabled = true },
            flake8 = { disabled = true },

            -- jedi autocompletion
            jedi_completion = { fuzzy = true },
          },
        },
      },
    }

    -- configure robot framework server
    local cwd = vim.fn.getcwd()
    OPERATING_SYSTEM = vim.loop.os_uname().sysname
    if OPERATING_SYSTEM == 'Windows_NT' then
      PYTHONPATH =
        { 'C:\\Users\\ayun\\zaya_app\\testrail\\robot', 'C:\\Users\\ayun\\zaya_app\\testrail\\robot\\resources', 'C:\\Users\\ayun\\zaya_app\\testrail' }
    else
      PYTHONPATH = { '~/zaya_app/testrail/robot', '~/zaya_app/testrail/robot/resources', '~/zaya_app/testrail' }
    end
    if OPERATING_SYSTEM == 'Windows_NT' then
      EXECUTABLE_PATH = 'C:\\Users\\ayun\\zaya_app\\.venv\\Scripts\\python.exe'
    else
      EXECUTABLE_PATH = '~/zaya_app/.venv/bin/python'
    end

    lspconfig['robotframework_ls'].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      root_dir = function(_)
        local cwd = vim.fn.getcwd()
        local robot_root = cwd .. '/robot'
        if vim.fn.isdirectory(robot_root) == 1 then
          return robot_root
        end
        return cwd
      end,
      settings = {
        robot = {
          -- pythonpath = PYTHONPATH,
          pythonpath = {
            vim.fn.getcwd() .. '/robot',
            vim.fn.getcwd() .. '/robot/resources',
          },
        },
      },
    }
  end,
}
