-- comment
local catUtils = require("nixCatsUtils")
if (catUtils.isNixCats and nixCats('lspDebugMode')) then
    vim.lsp.set_log_level("debug")
end
local old_ft_fallback = require('lze').h.lsp.get_ft_fallback()
require("lze").h.lsp.set_ft_fallback(function(name)
    local lspcfg = nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) or
        nixCats.pawsible({ "allPlugins", "start", "nvim-lspconfig" })
    if lspcfg then
        local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
        if not ok then
            ok, cfg = pcall(dofile, lspcfg .. "/lua/lspconfig/configs/" .. name .. ".lua")
        end
        return (ok and cfg or {}).filetypes or {}
    else
        return old_ft_fallback(name)
    end
end)

require("lze").load {
    {
        "nvim-lspconfig",
        for_cat = "general.always",
        on_require = { "lspconfig" },
        lsp = function(plugin)
            vim.lsp.config(plugin.name, plugin.lsp or {})
            vim.lsp.enable(plugin.name)
        end,
        before = function(_)
            vim.lsp.config('*', {
                on_attach = require("plugins.lsp_on_attach"),
            })
        end,
    },
    {
        "lua_ls",
        enabled = nixCats("lua") or false,
        lsp = {
            filetypes = { 'lua' },
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    formatters = {
                        ignoreComments = true,
                    },
                    signatureHelp = { enabled = true },
                    diagnostics = {
                        globals = { "nixCats", "vim" },
                        disable = { "missing-fields" },
                    },
                    telemetry = { enabled = false },
                }
            }
        }
    },
    {
        "nixd",
        enabled = nixCats("nix") or false,
        lsp = {
            filetypes = { 'nix' },
            settings = {
                nixd = {
                    nixpkgs = {
                        expr = nixCats.extra("nixdExtras.nixpkgs") or [[ import <nixpkgs> ]],
                    },
                    options = {
                        nixos = {
                            expr = nixCats.extra("nixdExtras.nixos_options")
                        },
                        ["home-manager"] = {
                            expr = nixCats.extra("nixdExtras.home_manager_options")
                        }
                    },
                    formatting = {
                        command = { "nixfmt" }
                    },
                    diagnostics = {
                        suppress = { "sema-escaping-with" },
                    },
                }
            }
        }
    },
    {
        "bash",
        enabled = nixCats("bash") or false,
        lsp = {
            filetypes = { 'sh' },
            settings = {
                bashls = {}
            }
        }
    },
    {
        "rust",
        enabled = nixCats("rust") and (os.execute('command -v rust-analyzer') == 0),
        lsp = {
            filetypes = { 'sh' },
            settings = {
                ["rust-analyzer"] = {
                    checkOnSave = true,
                    check = { command = "clippy", }
                }
            }
        }
    }
}
