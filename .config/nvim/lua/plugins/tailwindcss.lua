return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          -- add razor explicitely
          filetypes = {
            "html",
            "razor",
            "css",
            "scss",
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "vue",
            "svelte",
          },
          -- handle Razor like HTML
          init_options = {
            userLanguages = { razor = "html" },
          },
          settings = {
            tailwindCSS = {
              classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
              includeLanguages = { razor = "html" },
            },
          },
        },
      },
    },
  },
}
