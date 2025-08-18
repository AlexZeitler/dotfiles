return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "Issafalcon/neotest-dotnet", -- für dotnet test
      "nsidorenco/neotest-vstest", -- für .NET Framework via vstest.console
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(
        opts.adapters,
        require("neotest-dotnet")({
          -- optional:
          -- discovery_root = "solution", -- falls du am liebsten *.sln als Root willst
          -- dap = { justMyCode = false },
        })
      )
      -- Nur laden, wenn du auf Windows .NET Framework-Tests hast:
      local ok = pcall(function()
        table.insert(
          opts.adapters,
          require("neotest-vstest")({
            -- Pfad zu vstest.console.exe anpassen (Beispiel Build Tools 2022):
            -- vstest_cmd = "C:/Program Files/Microsoft Visual Studio/2022/BuildTools/Common7/IDE/CommonExtensions/Microsoft/TestWindow/vstest.console.exe",
            -- additional_args = { "/Platform:x64" },
          })
        )
      end)
      return opts
    end,
  },
}
