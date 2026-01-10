# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license
{
  description = "Generic NVim configuation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    plugins-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects/main";
      flake = false;
    };
  };

  # see :help nixCats.flake.outputs
  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (inputs.nixCats) utils;
      luaPath = ./.;
      forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
      # the following extra_pkg_config contains any values
      # which you want to pass to the config set of nixpkgs
      # import nixpkgs { config = extra_pkg_config; inherit system; }
      # will not apply to module imports
      # as that will have your system values
      extra_pkg_config = {
        # allowUnfree = true;
      };

      dependencyOverlays = # (import ./overlays inputs)
        [ (utils.standardPluginOverlay inputs) ];

      # :help nixCats.flake.outputs.categoryDefinitions.scheme
      categoryDefinitions =
        {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        }@packageDef:
        {
          # to define and use a new category, simply add a new list to a set here,
          # and later, you will include categoryname = true; in the set you
          # provide when you build the package using this builder function.
          # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

          # lspsAndRuntimeDeps:
          # this section is for dependencies that should be available
          # at RUN TIME for plugins. Will be available to PATH within neovim terminal
          # this includes LSPs
          lspsAndRuntimeDeps = with pkgs; {
            general = [
              curl
              ripgrep
              fd
              tree-sitter
            ];
            bash = [
              nodePackages.bash-language-server
              shfmt
              shellcheck
            ];
            lua = [
              stylua
              lua-language-server
            ];
            nix = [
              nixd
              nixfmt
            ];
            typst = [ tinymist ];
          };

          # This is for plugins that will load at startup without using packadd:
          startupPlugins = with pkgs.vimPlugins; {
            themer = builtins.getAttr (categories.colorscheme or "onedark") {
              "onedark" = onedark-nvim;
              "catppuccin" = catppuccin-nvim;
            };
            general = with pkgs.vimPlugins; [
              lze
              lzextras
              comment-nvim
              gitsigns-nvim
              which-key-nvim
              telescope-nvim
              telescope-fzf-native-nvim
              telescope-ui-select-nvim
              nvim-web-devicons
              plenary-nvim
              nvim-lspconfig
              lazydev-nvim
              fidget-nvim
              nvim-cmp
              luasnip
              cmp_luasnip
              cmp-nvim-lsp
              cmp-path
              todo-comments-nvim
              mini-nvim
              lspkind-nvim
              vim-tmux-navigator
              markdown-preview-nvim
            ];
            indent_line = with pkgs.vimPlugins; [ indent-blankline-nvim ];
            lint = with pkgs.vimPlugins; [ nvim-lint ];
            autopairs = with pkgs.vimPlugins; [ nvim-autopairs ];
            nvim-tree = with pkgs.vimPlugins; [
              nvim-tree-lua
              nvim-web-devicons
            ];
            format = with pkgs.vimPlugins; [ conform-nvim ];
            markdown = with pkgs.vimPlugins; [ markdown-preview-nvim ];
            treesitter = with pkgs.vimPlugins; [
              pkgs.neovimPlugins.treesitter-textobjects
              nvim-treesitter.withAllGrammars
            ];
          };

          # not loaded automatically at startup.
          # use with packadd and an autocommand in config to achieve lazy loading
          # this config uses lazy.nvim, so this isn't relevent
          optionalPlugins = with pkgs.vimPlugins; {
            rust = [
              rust-vim
              rustaceanvim
            ];
            typst = [ typst-preview-nvim ];

          };

          # shared libraries to be added to LD_LIBRARY_PATH
          # variable available to nvim runtime
          sharedLibraries = {
            general = {
              git = with pkgs; [ ];
            };
          };

          # environmentVariables:
          # this section is for environmentVariables that should be available
          # at RUN TIME for plugins. Will be available to path within neovim terminal
          environmentVariables = { };

          # If you know what these are, you can provide custom ones by category here.
          # If you dont, check this link out:
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
          extraWrapperArgs = { };

          # lists of the functions you would have passed to
          # python.withPackages or lua.withPackages

          # get the path to this python environment
          # in your lua config via
          # vim.g.python3_host_prog
          # or run from nvim terminal via :!<packagename>-python3
          extraPython3Packages = {
            test = (_: [ ]);
          };
          # populates $LUA_PATH and $LUA_CPATH
          extraLuaPackages = {
            test = [ (_: [ ]) ];
          };
        };

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions =
        let
          settings = {
            suffix-path = true;
            suffix-LD = true;
            aliases = [
              "vi"
              "vim"
              "nvim"
            ];
            wrapRc = true;
          };
          categories = {
            markdown = true;
            general = true;
            bash = true;
            lua = true;
            nix = true;
            typst = true;
            lint = true;
            format = true;
            themer = true;
            colorscheme = "onedark";
            treesitter = true;
            nvim-tree = true;
          };
        in
        {
          nixnvim =
            args@{ pkgs, name, ... }:
            {
              inherit settings categories;
              # see :help nixCats.flake.outputs.settings
              extra = { };
            };
          nixnvim-unwrapped =
            args@{ pkgs, name, ... }:
            {
              settings = settings // {
                wrapRc = false;
              };
              categories = categories;
              extra = { };

            };
        };
      defaultPackageName = "nixnvim";
      # see :help nixCats.flake.outputs.exports
    in
    forEachSystem (
      system:
      let
        nixCatsBuilder = utils.baseBuilder luaPath {
          inherit
            nixpkgs
            system
            dependencyOverlays
            extra_pkg_config
            ;
        } categoryDefinitions packageDefinitions;
        defaultPackage = nixCatsBuilder defaultPackageName;
        devPackage = nixCatsBuilder "nixnvim-unwrapped";
        # this is just for using utils such as pkgs.mkShell
        # The one used to build neovim is resolved inside the builder
        # and is passed to our categoryDefinitions and packageDefinitions
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # these outputs will be wrapped with ${system} by utils.eachSystem

        # this will make a package out of each of the packageDefinitions defined above
        # and set the default package to the one passed in here.
        packages = utils.mkAllWithDefault defaultPackage;

        # choose your package for devShell
        # and add whatever else you want in it.
        devShells = {
          default = pkgs.mkShell {
            name = "nixnvim-dev";
            packages = [ devPackage ];
            inputsFrom = [ ];
            shellHook = ''
              export NVIM_APPNAME=nixnvim-dev
              ln -sf ${builtins.getEnv "PWD"} $XDG_CONFIG_HOME/nvim
            '';
          };
        };

      }
    )
    // (
      let

        # these outputs will be NOT wrapped with ${system}

        # we also export a nixos module to allow reconfiguration from configuration.nix
        nixosModule = utils.mkNixosModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
        # and the same for home manager
        homeModule = utils.mkHomeModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
      in
      {
        # these outputs will be NOT wrapped with ${system}

        # this will make an overlay out of each of the packageDefinitions defined above
        # and set the default overlay to the one named here.
        overlays = utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        } categoryDefinitions packageDefinitions defaultPackageName;

        nixosModules.default = nixosModule;
        homeModules.default = homeModule;

        inherit utils;
        inherit (utils) templates;
      }
    );
}
