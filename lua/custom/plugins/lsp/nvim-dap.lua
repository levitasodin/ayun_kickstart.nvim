return {
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    config = function()
      local dap = require 'dap'

      local function get_python_path()
        local is_windows = vim.loop.os_uname().sysname:find 'Windows'

        -- 1. Check if there's an activated virtualenv
        local venv = os.getenv 'VIRTUAL_ENV'
        if venv then
          return is_windows and (venv .. '\\Scripts\\python.exe') or (venv .. '/bin/python')
        end

        -- 2. Check for `.venv` or `venv` folders in project
        local cwd = vim.fn.getcwd()
        local paths = is_windows and {
          cwd .. '\\.venv\\Scripts\\python.exe',
          cwd .. '\\venv\\Scripts\\python.exe',
        } or {
          cwd .. '/.venv/bin/python',
          cwd .. '/venv/bin/python',
        }

        for _, path in ipairs(paths) do
          if vim.fn.executable(path) == 1 then
            return path
          end
        end

        -- 3. Fallback to system Python
        local candidates = is_windows and { 'python.exe', 'python3.exe', 'py.exe' } or { 'python3', 'python' }
        for _, exe in ipairs(candidates) do
          local sys_python = vim.fn.exepath(exe)
          if sys_python ~= '' then
            return sys_python
          end
        end

        error 'Unable to find a valid Python interpreter'
      end

      -- Adapter for debugpy (make sure it's installed: `pip install debugpy`)
      dap.adapters.python = {
        type = 'executable',
        command = get_python_path(),
        args = { '-m', 'debugpy.adapter' },
      }

      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = get_python_path,
        },
      }

      -- Optional: keybindings
      vim.keymap.set('n', '<F5>', function()
        dap.continue()
      end)
      vim.keymap.set('n', '<F10>', function()
        dap.step_over()
      end)
      vim.keymap.set('n', '<F11>', function()
        dap.step_into()
      end)
      vim.keymap.set('n', '<F12>', function()
        dap.step_out()
      end)
      vim.keymap.set('n', '<Leader>b', function()
        dap.toggle_breakpoint()
      end)
    end,
  },
}
-- return {
--   'mfussenegger/nvim-dap',
--   event = 'VeryLazy',
--   config = function()
--     local dap = require 'dap'
--
--     -- [ayun]:      Some functions below to find the correct Python path and
--     --              detect whether or not it's to use the virtual environment installation
--     --              or the system installation.
--     -- ========================================================================================
--     local function get_system_python()
--       local candidates = { 'python3', 'python' }
--
--       for _, exe in ipairs(candidates) do
--         local path = vim.fn.exepath(exe)
--         if path ~= '' then
--           return path
--         end
--       end
--       error 'No system Python executable found'
--     end
--
--     local function get_python_path()
--       if os.getenv 'VIRTUAL_ENV' then
--         return os.getenv 'VIRTUAL_ENV' .. '/bin/python'
--       end
--
--       local cwd = vim.fn.getcwd()
--       local paths = {
--         cwd .. '/.venv/bin/python',
--         cwd .. '/venv/bin/python',
--       }
--       for _, path in ipairs(paths) do
--         if vim.fn.executable(path) == 1 then
--           return path
--         end
--       end
--
--       return get_system_python
--     end
--     -- ========================================================================================
--
--     dap.adapters.python = {
--       type = 'executable',
--       command = os.getenv 'HOME' .. '/.virtualenvs/debugpy/bin/python',
--       args = { '-m', 'Debugpy.adapter' },
--     }
--     vim.keymap.set('n', '<F5>', function()
--       dap.continue()
--     end)
--     vim.keymap.set('n', '<F10>', function()
--       dap.step_over()
--     end)
--     vim.keymap.set('n', '<F11>', function()
--       dap.step_into()
--     end)
--     vim.keymap.set('n', '<F12>', function()
--       dap.step_out()
--     end)
--     vim.keymap.set('n', '<leader>b', function()
--       dap.toggle_breaktpoint()
--     end)
--   end,
-- }
