local W = require("USER.utils.widgets")
local D = require("USER.utils.dir")

return {
  {
    -- "echasnovski/mini.tabline",
    dir = D.plugin .. "mini.tabline",
    lazy = false,
    config = function()
      require("mini.tabline").setup({
        show_icons = true,
        tabpage_section = "right",
      })
    end
  },
  {
    -- "echasnovski/mini.starter",
    dir = D.plugin .. "mini.starter",
    cmd = "MiniStarter",
    config = function()
      local starter = require("mini.starter")
      starter.setup({
        autoopen = false,
        items = {
          -- Custom actions
          { action = "bdelete", name = "Exit this buffer", section = "Builtin (actions)" },
          { action = "qall", name = "Quit Nvim", section = "Builtin (actions)" },
          { action = "enew", name = "Create a new buffer", section = "Builtin (actions)" },
          { action = "NnnPicker", name = "Open file manager", section = "Builtin (actions)" },
          { action = "FzfLua", name = "Open fuzzy finder", section = "Builtin (actions)" },
          starter.sections.recent_files(9, true),
          starter.sections.recent_files(30, false),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(),
          starter.gen_hook.indexing("section"),
          starter.gen_hook.padding(8, 1),
        },
        header = W.app_date_and_time(),
        footer = "<C-c> Close this buffer",
      })
    end
  },
  {
    -- "tamton-aquib/staline.nvim",
    -- "farias-hecdin/staline.nvim",
    dir = D.plugin .. "__staline.nvim",
    lazy = false,
    config = function()
      require("staline").setup({
        slots = {
          counter = function() return "" .. W.app_counter() .. " " end,
          lazy = function() return " " .. W.app_lazy() .. " " end,
          clock = function() return " " .. W.app_clock() .. " " end,
        },
        defaults = {
          expand_null_ls = false, -- This expands out all the null-ls sources to be shown
          full_path = false,
          line_column = "[%l/%L]:%c  %p%%", -- `:h stl` to see all flags.
          fg = "#000000", -- Foreground text color.
          bg = "#000000", -- Default background is transparent.
          inactive_color = "#000000",
          inactive_bgcolor = "#000000",
          true_colors = true, -- true lsp colors.
          font_active = "none", -- "bold", "italic", "bold,italic", etc
          mod_symbol = " ",
          lsp_client_symbol = " ",
          lsp_client_character_length = 12,
          branch_symbol = " ",
          null_ls_symbol = "" -- A symbol to indicate that a source is coming from null-ls
        },
        mode_colors = {
          ["c"]  = "#FFFFFF",
          ["n"]  = "#2BBB4F",
          ["i"]  = "#FFFF00",
          ["v"]  = "#0091EA",
          ["V"]  = "#90CAF9",
          [""] = "#BA68C8",
          ["r"]  = "#F06292",
          ["R"]  = "#CC5500",
          ["t"]  = "#FFA000",
        },
        mode_icons = {
          ["c"]  = " COM",
          ["n"]  = " NOR",
          ["i"]  = " INS",
          ["v"]  = " VIS",
          ["V"]  = " V-L",
          [""] = " V-V",
          ["r"]  = " REP",
          ["R"]  = " R-L",
          ["t"]  = " TER",
          ["s"]  = " SEL",
          ["S"]  = " S-L",
          ["ic"] = " IC ",
        },
        sections = {
          left  = { "-mode", "file_size", "counter", "%m", "branch" },
          mid   = { "line_column" },
          right = { "lsp_name", " ", "diagnostics", "lazy", "-clock", }
        },
        lsp_symbols = {
          Error = " ",
          Info = " ",
          Warn = " ",
          Hint = " "
        },
        special_table = {
          help = { "Help", " " },
        }
      })
    end
  }
}
