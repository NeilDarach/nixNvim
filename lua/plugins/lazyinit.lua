local pluginList = nil
local nixLazyPath = nil

if require("nixCatsUtils").isNixCats then
	local allPlugins = require("nixCats").pawsible.allPlugins
	-- this list tells lazy.nvim not to download these plugins
	pluginList = require("nixCatsUtils.lazyCat").mergePluginTables(allPlugins.start, allPlugins.opt)
	-- some have slightly different names
	pluginList[ [[Comment.nvim]] ] = ""
	pluginList[ [[LuaSnip]] ] = ""

	nixLazyPath = allPlugins.start[ [[lazy.nvim]] ]
end

local function getlockfilepath()
	if require("nixCatsUtils").isNixCats and type(require("nixCats").settings.unwrappedCfgPath) == "string" then
		return require("nixCats").settings.unwrappedCfgPath .. "/lazy-lock.json"
	else
		return vim.fn.stdpath("config") .. "/lazy-lock.json"
	end
end

local lazyOptions = {
	lockfile = getlockfilepath(),
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
}

-- Configure and install plugins
-- check status with :Lazy

require("nixCatsUtils.lazyCat").setup(pluginList, nixLazyPath, {
	"tpope/vim-sleuth", -- just load

	-- set name because the plugin name and the download name don't match
	-- opts = {} is the same as require('Comment').setup({})
	{ "numToStr/Comment.nvim", name = "comment.nvim", opts = {} },

	-- actually supply some options
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
	{
		"navarasu/onedark.nvim",
		opts = {
			style = "darker",
			colors = {
				comment_grey = "#acb2bc",
			},
			highlights = {
				["@comment"] = { fg = "$green" },
			},
		},
		priority = 1000, -- before other plugins
		init = function()
			vim.cmd.colorscheme("onedark")
			-- vim.cmd.hi 'Comment gui=none'
		end,
	},
	{ -- show pending keybinds
		"folke/which-key.nvim",
		event = "VimEnter", -- the loading event
		config = function() -- this function runs after loading
			require("which-key").setup()
			require("which-key").add({
				{ "<leader>c", group = "[C]ode" },
				{ "<leader>c_", hidden = true },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>d_", hidden = true },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>r_", hidden = true },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>s_", hidden = true },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>t_", hidden = true },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>w_", hidden = true },
				{
					mode = { "v" },
					{ "<leader>h", group = "Git [H]unk" },
					{ "<leader>h_", hidden = true },
				},
			})
		end,
	},
	{ -- Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = require("nixCatsUtils").lazyAdd("make"),
				cond = require("nixCatsUtils").lazyAdd(function()
					return vim.fn.executable("make") == 1
				end),
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			-- :Telescope help_tags
			-- help - insert mode <c-/>, normal mode ?
			require("telescope").setup({
				-- :help telescope_setup()
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})
			-- Enable telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			-- :help telescope.builtin
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			-- override default behaviour and theme
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewr = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in  Open Files" })

			-- search config files
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},
	{ -- LSPs
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Mason only required if nix isn't used
			{
				"williamboman/mason.nvim",
				enabled = require("nixCatsUtils").lazyAdd(true, false),
				config = true,
			},
			{
				"williamboman/mason-lspconfig.nvim",
				enabled = require("nixCatsUtils").lazyAdd(true, false),
			},
			{
				"whoIsSethDaniel/mason-tool-installer.nvim",
				enabled = require("nixCatsUtils").lazyAdd(true, false),
			},
			-- Status updates
			{ "j-hui/fidget.nvim", opts = {} },
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						{ path = require("nixCats").nixCatsPath .. "/lua", words = { "nixCats" } },
					},
				},
			},
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.semanticTokensProvider then
						client.server_capabilities.semanticTokensProvider = nil
					end
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					-- Jump to the definition of the word under the cursor
					-- To jump back, press <C-t>
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gt", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementations")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
					map("K", vim.lsp.buf.hover, "Hover documentation")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Highlight references of the word under the cursor when it rests there
					--      -- :help CursorHold
					--      -- The highlight is cleared when the cursor moves
					if client and client.server_capabilities.documentHighlightProvider then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detatch", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
			local servers = {}
			-- nixd is not availble in mason
			if require("nixCatsUtils").isNixCats then
				servers.nixd = {}
			else
				servers.rnix = {}
				servers.nil_ls = {}
			end
			servers.lua_ls = {
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						diagnostics = {
							globals = { "nixCats" },
							disable = { "missing-fields" },
						},
					},
				},
			}

			if require("nixCatsUtils").isNixCats then
				for server_name, _ in pairs(servers) do
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
						settings = servers[server_name],
						filetypes = (servers[server_name] or {}).filetypes,
						cmd = (servers[server_name] or {}).cmd,
						root_pattern = (servers[server_name] or {}).root_pattern,
					})
				end
			else
				require("mason").setup()
				local ensure_installed = vim.tbl_keys(servers or {})
				vim.list_extend(ensure_installed, {
					"stylua", -- for formatting lua code
				})
				require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
				require("mason-lspconfig").setup({
					handlers = {
						function(server_name)
							local server = servers[server_name] or {}
							server.capabilities =
								vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
							require("lspconfig")[server_name].setup(server)
						end,
					},
				})
			end
		end,
	},

	{ --Auto format
		"stevearc/conform.nvim",
		lazy = false,
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				return {
					timeout_ms = 500,
					lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
			},
		},
	},
	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				-- nixcats uses a different filename
				name = "luasnip",
				build = require("nixCatsUtils").lazyAdd((function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)()),
				dependencies = {},
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			-- :help cmp
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				-- :help ins-completion
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.confirm({ select = true }),
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
			})
		end,
	},

	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = require("nixCatsUtils").lazyAdd(":TSUpdate"),
		opts = {
			-- NOTE: nixCats: use lazyAdd to only set these 2 options if nix wasnt involved.
			-- because nix already ensured they were installed.
			ensure_installed = require("nixCatsUtils").lazyAdd({
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"vim",
				"vimdoc",
			}),
			auto_install = require("nixCatsUtils").lazyAdd(true, false),

			highlight = {
				enable = true,
				-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
				--  If you are experiencing weird indenting issues, add the language to
				--  the list of additional_vim_regex_highlighting and disabled languages for indent.
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
		config = function(_, opts)
			-- [[ Configure Treesitter ]] See `:help nvim-treesitter`

			-- Prefer git instead of curl in order to improve connectivity in some environments
			require("nvim-treesitter.install").prefer_git = true
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup(opts)

			-- There are additional nvim-treesitter modules that you can use to interact
			-- with nvim-treesitter. You should go explore a few and see what interests you:
			--
			--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
			--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
			--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
		end,
	},
	{ -- Highlight todo comments
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependences = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{ -- various small plugins
		"echasnovski/mini.nvim",
		config = function()
			-- Better around/inside text objects
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},
	require("plugins.indent_line"),
	require("plugins.autopairs"),
	require("plugins.gitsigns"),
	require("plugins.lint"),
	require("plugins.neo-tree"),
}, lazyOptions)

-- modeline
-- vim: ts=2 sts=2 sw=2 et
