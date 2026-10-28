local focus_group = vim.api.nvim_create_augroup('dot_fzf_focus', { clear = true })

require('fzf-lua').setup({
  -- Keep the familiar side-by-side layout while using fzf's matcher.
  'telescope',
  winopts = {
    on_create = function(event)
      vim.api.nvim_clear_autocmds({ group = focus_group })
      vim.api.nvim_create_autocmd('WinEnter', {
        group = focus_group,
        callback = function()
          -- Wait for window switches to finish; floating previews stay usable.
          vim.schedule(function()
            if not vim.api.nvim_win_is_valid(event.winid)
              or vim.api.nvim_win_get_buf(event.winid) ~= event.bufnr then
              return
            end
            local target = vim.api.nvim_get_current_win()
            if target == event.winid or vim.api.nvim_win_get_config(target).relative ~= '' then
              return
            end
            require('fzf-lua').hide()
            -- Hiding restores the source window; keep the user's chosen window.
            if vim.api.nvim_win_is_valid(target) then
              vim.api.nvim_set_current_win(target)
            end
          end)
        end,
      })
    end,
    on_close = function()
      vim.api.nvim_clear_autocmds({ group = focus_group })
    end,
    preview = {
      wrap = true,
    },
  },
  files = {
    fd_opts = [[--color=never --type f --type l --exclude .git --exclude .jj --exclude '*.o']],
    rg_opts = [[--color=never --files -g '!.git' -g '!.jj' -g '!*.o']],
  },
  grep = {
    rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --max-depth 10 --glob '!*.o' -e]],
  },
  git = {
    files = {
      cmd = [[git ls-files --exclude-standard -- ':!:*.o']],
    },
  },
})
