-- ensure that xmllint is installed (good practice)
if vim.fn.executable('xmllint') == 1 then
  -- set formatprg
  vim.bo.formatprg = 'xmllint --noblanks --format -'
  -- ensure we use formatprg istead of formatexpr
  vim.bo.formatexpr = ''
end
