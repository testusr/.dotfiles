local lspconfig = require('lspconfig')
local noop = function() end

require('mason-lspconfig').setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
      on_attach = lsp_attach,
      capabilities = lsp_capabilities,
    })
  end,
  --['jdtls'] = noop,
})
