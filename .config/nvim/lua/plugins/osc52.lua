return {
  "ojroques/nvim-osc52",
  config = function()
    local osc52 = require("osc52")

    -- Nur Yanks vom Benutzer im Normal- oder Visuellen Modus ins OSC52-Clipboard
    vim.api.nvim_create_autocmd("TextYankPost", {
      callback = function()
        -- Prüfen: Operator ist 'y', kein spezielles Register, und Modus ist n oder v
        local mode = vim.fn.mode()
        if vim.v.event.operator == "y" and vim.v.event.regname == "" and (mode == "n" or mode == "v") then
          osc52.copy_register('"')
        end
      end,
    })

    -- Visueller Modus explizit binden (optional)
    vim.keymap.set("v", "y", function()
      osc52.copy_visual()
    end, { noremap = true, silent = true })
  end,
}
