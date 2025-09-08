return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        direction = "horizontal",
        size = 20,
        open_mapping = [[<C-t><C-t>]],
        hide_numbers = true,
        shade_terminals = true,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_mode = true,
        autochdir = true,
        close_on_exit = true,
        shell = vim.o.shell,
        -- Fullscreen float settings
        float_opts = {
          border = "curved",
          width = function() return vim.o.columns end,
          height = function() return vim.o.lines end,
        },
      })

      local TermMod = require("toggleterm.terminal")
      local Terminal = TermMod.Terminal

      local last_id = 1
      local fullscreen = false

      -- Remember last-used terminal id and tidy buffer
      vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter" }, {
        pattern = "term://*toggleterm#*",
        callback = function()
          local id = vim.b.toggle_number
          if id then last_id = id end
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.signcolumn = "no"
          vim.cmd("startinsert")
        end,
      })

      -- Run a command from any mode (escape terminal first)
      local function run_term_cmd(cmd)
        if vim.fn.mode() == "t" then
          local esc = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
          vim.api.nvim_feedkeys(esc, "n", false)
        end
        vim.cmd(cmd)
      end

      -- Get or create a terminal by id
      local function get_term_by_id(id)
        local ok_get, term = pcall(TermMod.get, id)
        if ok_get and term then return term end

        local ok_all, list = pcall(TermMod.get_all)
        if ok_all and list then
          for _, t in ipairs(list) do
            if t.id == id then return t end
          end
        end

        return Terminal:new({ id = id, direction = "horizontal" })
      end

      -- Toggle a specific terminal (1..5)
      local function toggle_id(id)
        last_id = id
        fullscreen = false
        run_term_cmd(string.format("%dToggleTerm", id))
      end

      -- Open next terminal id in cycle (1..5)
      local function open_next()
        local next_id = (last_id % 5) + 1
        toggle_id(next_id)
      end

      -- Close (hide) current if inside one; else last used
      local function close_current_or_last()
        local id = vim.b.toggle_number or last_id
        run_term_cmd(string.format("%dToggleTerm", id))
      end

      -- Maximize/demaximize current terminal
      local function toggle_fullscreen()
        local id = vim.b.toggle_number or last_id or 1
        local term = get_term_by_id(id)

        if fullscreen then
          term.direction = "horizontal"
          term:open(20) -- restore split height
          fullscreen = false
        else
          term.direction = "float"
          term:open() -- fullscreen float
          fullscreen = true
        end
      end

      -- Popup menu of open terminals
      local function menu_terminals()
        local ok_all, terminals = pcall(TermMod.get_all)
        terminals = (ok_all and terminals) or {}
        if #terminals == 0 then
          vim.notify("No open terminals", vim.log.levels.INFO)
          return
        end

        local items = {}
        for _, term in ipairs(terminals) do
          local id = term.id
          local label = term.display_name or term.name or ("Terminal " .. id)
          table.insert(items, { label = label, id = id })
        end

        vim.ui.select(items, {
          prompt = "Select terminal:",
          format_item = function(item) return string.format("[%d] %s", item.id, item.label) end,
        }, function(choice)
          if choice then
            last_id = choice.id
            run_term_cmd(string.format("%dToggleTerm", choice.id))
          end
        end)
      end

      -- <C-t>1..5 → toggle terminals 1..5
      for i = 1, 5 do
        for _, mode in ipairs({ "n", "i", "t" }) do
          vim.keymap.set(mode, "<C-t>" .. i, function() toggle_id(i) end,
            { noremap = true, silent = true, desc = "Toggle Terminal " .. i })
        end
      end

      -- <C-t><C-t> → toggle last (escape first in terminal)
      vim.keymap.set("t", "<C-t><C-t>", [[<C-\><C-n><cmd>ToggleTerm<CR>]],
        { noremap = true, silent = true, desc = "Toggle last terminal" })

      -- <C-t>a → open next terminal (cycle 1..5)
      for _, mode in ipairs({ "n", "i", "t" }) do
        vim.keymap.set(mode, "<C-t>a", open_next,
          { noremap = true, silent = true, desc = "Open next Terminal (cycle 1..5)" })
      end

      -- <C-t>x → close current/last
      for _, mode in ipairs({ "n", "i", "t" }) do
        vim.keymap.set(mode, "<C-t>x", close_current_or_last,
          { noremap = true, silent = true, desc = "Close current/last Terminal" })
      end

      -- <C-t>z → fullscreen toggle
      for _, mode in ipairs({ "n", "i", "t" }) do
        vim.keymap.set(mode, "<C-t>z", toggle_fullscreen,
          { noremap = true, silent = true, desc = "Toggle fullscreen terminal" })
      end

      -- <C-t>m → menu to pick an open terminal
      for _, mode in ipairs({ "n", "i", "t" }) do
        vim.keymap.set(mode, "<C-t>m", menu_terminals,
          { noremap = true, silent = true, desc = "Menu: choose terminal" })
      end

      -- <Esc><Esc> → leave terminal insert mode
      vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], {
        noremap = true, silent = true, nowait = true, desc = "Exit terminal mode with <Esc><Esc>"
      })

      -- which-key integration
      local ok_wk, wk = pcall(require, "which-key")
      if ok_wk then
        local term_keys = {
          ["<C-t>"] = {
            name = "Terminal",
            ["<C-t>"] = { "<cmd>ToggleTerm<CR>", "Toggle last terminal" },
            ["1"] = { function() toggle_id(1) end, "Terminal 1" },
            ["2"] = { function() toggle_id(2) end, "Terminal 2" },
            ["3"] = { function() toggle_id(3) end, "Terminal 3" },
            ["4"] = { function() toggle_id(4) end, "Terminal 4" },
            ["5"] = { function() toggle_id(5) end, "Terminal 5" },
            a = { open_next, "Open next terminal (cycle)" },
            x = { close_current_or_last, "Close current/last terminal" },
            -- is not really working yet
            -- z = { toggle_fullscreen, "Fullscreen (float <-> horizontal)" },
            m = { menu_terminals, "Menu: choose terminal" },
          },
        }
        wk.register(term_keys, { mode = "n" })
        wk.register(term_keys, { mode = "i" })
        wk.register(term_keys, { mode = "t" })
        -- show <Esc><Esc> exit
        wk.register({ ["<Esc><Esc>"] = { [[<C-\><C-n>]], "Exit terminal mode" } }, { mode = "t" })
      end
    end,
  },
}

