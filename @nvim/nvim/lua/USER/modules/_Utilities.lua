local D = require("USER.utils.dir")

return {
  {
    -- "willothy/flatten.nvim",
    dir = D.plugin .. "flatten.nvim",
    config = true,
    -- or pass configuration with
    -- opts = {  }
    -- Ensure that it runs first to minimize delay when opening file from terminal
    lazy = false,
    priority = 1001,
  },
  {
    -- "jbyuki/quickmath.nvim",
    dir = D.plugin .. "quickmath-nvim",
    cmd = { "Quickmath", "QuickmathNow" },
    config = true,
  },
}
