local D = require("USER.dir")

return {
  {
    -- "nvim-treesitter/nvim-treesitter-context",
    dir = D.plugin .. "nvim-treesitter-context",
    event = "InsertEnter",
    config = function()
      require("treesitter-context").setup()
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    pin = true,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- list of parsers to ignore installing (for "all")
        ignore_install = { "css" },
        -- enable syntax highlighting
        highlight = {
          enable = true, -- false will disable the whole extension
          disable = function(lang, bufnr) -- Disable in large C++ buffers
            file = (lang == "markdown" and vim.api.nvim_buf_line_count(bufnr) > 500)
            return file
          end,
        },
        matchup = {
          enable = true,
        },
        -- enable indentation
        indent = {
          enable = true,
          disable = { "python" }
        },
        -- enable autotagging (w/ nvim-ts-autotag plugin)
        autotag = { enable = true },
        -- ensure these language parsers are installed
        ensure_installed = {
          "astro",
          "bash",
          "html",
          "javascript",
          "lua",
          "markdown",
          "markdown_inline",
          "php",
          "python",
          "sql",
          "typescript",
          "vue",
        },
        -- auto install above language parsers
        auto_install = false,
      })
    end
  }
}
