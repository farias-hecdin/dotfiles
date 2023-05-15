return {
  {
    "VonHeikemen/lsp-zero.nvim",
    lazy = false,
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- Mason
      require('mason').setup()
      require("mason.settings").set({
        ui = {
          border = "rounded",
          icons = {
            package_pending = " ",
            package_installed = " ",
            package_uninstalled = " ",
          },
          keymaps = {
            toggle_server_expand = "<CR>",
            install_server = "I",
            update_server = "u",
            check_server_version = "c",
            update_all_servers = "U",
            check_outdated_servers = "C",
            uninstall_server = "X",
            cancel_installation = "<C-c>",
          },
        },
        max_concurrent_installers = 2,
      })

      -- LspZero
      local lsp = require("lsp-zero")
      lsp.preset("recommended") -- recommended / lsp-compe / lsp-only / manual-setup
      lsp.set_preferences({
        suggest_lsp_servers = true,
        sign_icons = {
          error = 'E',
          warn = 'W',
          hint = 'H',
          info = 'I'
        }
      })
      -- List of LSP server (https://langserver.org/#arbitraryExecutionFootnote)
      lsp.ensure_installed({
        "tsserver",     -- Javascript/Typescript
        -- "phpactor",  -- PHP
        -- "pyright",   -- Python
      })
      lsp.nvim_workspace()
      lsp.setup()
      -- Reserve space for diagnostic icons
      vim.opt.signcolumn = "yes"
    end
  }
}
