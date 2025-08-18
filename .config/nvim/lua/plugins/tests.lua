return {
  -- … deine deps (nvim-nio, plenary, treesitter, Issafalcon/neotest-dotnet) …
  {
    "nvim-neotest/neotest",
    lazy = false,
    opts = {
      adapters = {
        require("neotest-dotnet")({
          discovery_root = "solution",
          dap = { justMyCode = false }, -- Debug in allem Code
          dotnet_additional_args = { "--configuration", "Debug" },
        }),
      },
    },
    keys = {
      {
        "<leader>tT",
        function()
          require("neotest").run.run({ strategy = "dap", extra_args = { "--configuration", "Debug" } })
        end,
        desc = "Test debug (nearest)",
      },
    },
  },
}
