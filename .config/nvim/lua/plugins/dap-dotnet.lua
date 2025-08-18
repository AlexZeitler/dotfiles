-- Debugging for .NET / ASP.NET Core via nvim-dap + netcoredbg
-- Notes:
-- - Comments in English (per your preference)
-- - 2-space indentation
-- - Works with LazyVim; ensures netcoredbg via mason-nvim-dap
-- - Provides: Launch (pick DLL), Launch ASP.NET Core (auto-pick), Attach to process

return {
  -- Ensure the adapter is installed
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      ensure_installed = { "netcoredbg" },
      automatic_installation = true,
    },
  },

  -- Core DAP setup
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")

      -- Resolve netcoredbg installed by Mason
      local mason = vim.fn.stdpath("data") .. "/mason"
      local netcoredbg = mason .. "/bin/netcoredbg"
      if vim.fn.executable(netcoredbg) == 0 then
        -- Fallback for some setups
        netcoredbg = mason .. "/packages/netcoredbg/netcoredbg/netcoredbg"
      end

      dap.adapters.coreclr = {
        type = "executable",
        command = netcoredbg,
        args = { "--interpreter=vscode" },
      }

      -- Helpers --------------------------------------------------------------

      -- Project root: prefer git root, else cwd
      local function project_root()
        local git = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if git and git ~= "" then
          return git
        end
        return vim.fn.getcwd()
      end

      -- Find candidate DLLs under bin/Debug/*/*.dll
      local function find_debug_dlls()
        local root = project_root()
        -- Example matches: bin/Debug/net8.0/YourProject.dll
        local pattern = root .. "/bin/Debug/*/*.dll"
        local matches = vim.split(vim.fn.glob(pattern), "\n", { trimempty = true })
        -- Filter out test DLLs if user is launching web app
        return matches
      end

      local function pick_debug_dll(cb)
        local dlls = find_debug_dlls()
        if #dlls == 0 then
          vim.notify("No Debug DLLs found. Build first: dotnet build", vim.log.levels.WARN)
          return
        end
        vim.ui.select(dlls, { prompt = "Select DLL to debug:" }, function(choice)
          if choice then
            cb(choice)
          end
        end)
      end

      local function default_env()
        -- Common ASP.NET Core env for local debugging
        return {
          ASPNETCORE_ENVIRONMENT = "Development",
          DOTNET_ENVIRONMENT = "Development",
        }
      end

      -- Optional: cheap "preLaunch" build (non-blocking notification on failure)
      local function try_build()
        local root = project_root()
        local cmd = { "dotnet", "build", "-c", "Debug" }
        vim.fn.jobstart(cmd, {
          cwd = root,
          stdout_buffered = true,
          stderr_buffered = true,
          on_stderr = function(_, data)
            if data and #data > 0 then
              -- show nothing noisy; build output is often long
            end
          end,
          on_exit = function(_, code)
            if code ~= 0 then
              vim.schedule(function()
                vim.notify("dotnet build failed. DLL might be outdated.", vim.log.levels.WARN)
              end)
            end
          end,
        })
      end

      -- DAP configurations ---------------------------------------------------

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch (pick DLL)",
          request = "launch",
          program = function()
            try_build()
            return coroutine.create(function(co)
              pick_debug_dll(function(choice)
                coroutine.resume(co, choice)
              end)
            end)
          end,
          cwd = function()
            return project_root()
          end,
          env = default_env(),
          stopAtEntry = false,
          -- args = { "--urls", "http://localhost:5000" }, -- uncomment if you want a fixed URL
        },
        {
          type = "coreclr",
          name = "Launch ASP.NET Core (auto)",
          request = "launch",
          program = function()
            try_build()
            local dlls = find_debug_dlls()
            if #dlls == 0 then
              error("No Debug DLLs found under bin/Debug/*/*.dll. Run `dotnet build` first.")
            end
            -- Heuristic: prefer a DLL that is NOT a *.Tests.dll
            for _, p in ipairs(dlls) do
              if not p:match("%.Tests%.dll$") then
                return p
              end
            end
            -- Fallback: first entry
            return dlls[1]
          end,
          cwd = function()
            return project_root()
          end,
          env = default_env(),
          stopAtEntry = false,
        },
        {
          type = "coreclr",
          name = "Attach (pick process)",
          request = "attach",
          processId = require("dap.utils").pick_process,
          cwd = function()
            return project_root()
          end,
        },
      }

      -- DAP UI (optional but handy)
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Quality-of-life keymaps (LazyVim already has many, these are safe)
      local map = vim.keymap.set
      map("n", "<leader>dc", function()
        require("dap").continue()
      end, { desc = "DAP Continue" })
      map("n", "<leader>db", function()
        require("dap").toggle_breakpoint()
      end, { desc = "DAP Toggle Breakpoint" })
      map("n", "<leader>do", function()
        require("dap").step_over()
      end, { desc = "DAP Step Over" })
      map("n", "<leader>di", function()
        require("dap").step_into()
      end, { desc = "DAP Step Into" })
      map("n", "<leader>dO", function()
        require("dap").step_out()
      end, { desc = "DAP Step Out" })
      map("n", "<leader>dr", function()
        require("dap").repl.open()
      end, { desc = "DAP REPL" })
      map("n", "<leader>du", function()
        require("dapui").toggle()
      end, { desc = "DAP UI Toggle" })
    end,
  },
}
