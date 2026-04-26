-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      use_libuv_file_watcher = true, -- auto-detect external filesystem changes
      filtered_items = {
        visible = true, -- show dotfiles by default
        hide_dotfiles = false,
        hide_gitignored = true,
        never_show = { '.git' },
      },
      window = {
        mappings = {
          ['<space>'] = 'none', -- free up leader key so <Space> keymaps work in neo-tree
          ['t'] = 'none', -- free up for <leader>t* keymaps (use Enter to open files)
          ['s'] = 'none', -- free up for <leader>s* keymaps (use Enter to open files)
          ['\\'] = 'close_window',
          ['E'] = 'expand_all_subnodes',
          ['z'] = 'close_all_nodes',
          ['Y'] = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            if node.type ~= 'directory' then
              path = vim.fn.fnamemodify(path, ':h')
            end
            vim.fn.setreg('+', path)
            vim.notify(path, vim.log.levels.INFO)
          end,
          ['y'] = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg('+', path)
            vim.notify(path, vim.log.levels.INFO)
          end,
          ['gE'] = 'expand_git_changed_dirs',
        },
      },

      commands = {
        expand_git_changed_dirs = function(state)
          local fs = require 'neo-tree.sources.filesystem'

          -- Find git root
          local git_root = vim.trim(vim.fn.system 'git rev-parse --show-toplevel')
          if vim.v.shell_error ~= 0 then
            vim.notify('[neo-tree] Not inside a git repo', vim.log.levels.WARN)
            return
          end

          -- Collect changed files: unstaged + staged + untracked, deduplicated
          local cmd = 'git -C '
            .. vim.fn.shellescape(git_root)
            .. ' diff --name-only && git -C '
            .. vim.fn.shellescape(git_root)
            .. ' diff --name-only --cached && git -C '
            .. vim.fn.shellescape(git_root)
            .. ' ls-files --others --exclude-standard'
          local raw = vim.fn.systemlist(cmd)

          local seen, files = {}, {}
          for _, f in ipairs(raw) do
            f = vim.trim(f)
            if f ~= '' and not seen[f] then
              seen[f] = true
              table.insert(files, f)
            end
          end

          if #files == 0 then
            vim.notify('[neo-tree] No git changes found', vim.log.levels.INFO)
            return
          end

          -- Build the list of ancestor dirs to open (stop at the parent of each changed file)
          local dirs_to_open = {}
          local dirs_seen = {}
          for _, rel in ipairs(files) do
            local parts = vim.split(rel, '/', { plain = true })
            local current = git_root
            for i = 1, #parts - 1 do
              current = current .. '/' .. parts[i]
              if not dirs_seen[current] then
                dirs_seen[current] = true
                table.insert(dirs_to_open, current)
              end
            end
          end

          -- Use neo-tree's force_open_folders to collapse all + expand only changed paths
          state.force_open_folders = dirs_to_open

          fs.navigate(state, state.path, nil, function()
            state.force_open_folders = nil
            vim.notify(('[neo-tree] %d changed file(s) in %d directories'):format(#files, #dirs_to_open), vim.log.levels.INFO)
          end)
        end,
      },
    },
  },
}
