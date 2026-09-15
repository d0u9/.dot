-- The parsers to install, shared by plugins/configs/nvim-treesitter.lua and
-- the bootstrap in apps/nvim-install.sh.
--
-- `just` comes from IndianBoy42/tree-sitter-just, which nvim-treesitter now
-- knows about itself -- the separate plugin is no longer needed.
return {
  'bash', 'c', 'comment', 'cpp', 'css', 'go', 'html', 'javascript', 'json',
  'json5', 'just', 'kdl', 'lua', 'markdown', 'python', 'ruby', 'rust',
  'toml', 'yaml',
}
