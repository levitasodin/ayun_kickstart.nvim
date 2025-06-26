return {
  'williamboman/mason.nvim',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
  },
  config = function()
    -- import mason
    local mason = require 'mason'

    -- import mason-lspconfig
    local mason_lspconfig = require 'mason-lspconfig'

    -- enable mason and configure icons
    mason.setup {
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➝',
          package_uninstalled = '✗',
        },
      },
    }

    mason_lspconfig.setup {
      -- ensure the following LSPs are installed
      ensure_installed = {
        'pylsp',
        'lua_ls',
      },
      -- automatically install configured servers
      automatic_installation = true,
    }
  end,
}
