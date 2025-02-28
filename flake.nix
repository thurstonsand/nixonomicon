{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:nixos/nixpkgs/nixos-unstable?dir=lib";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    # don't use "follows" for nixpkgs here, as this can cause compat issues
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvchad4nix = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      # url = "github:nix-community/nixos-vscode-server";
      # waiting on this PR to land
      # https://github.com/nix-community/nixos-vscode-server/pull/78
      url = "github:Ten0/nixos-vscode-server/support_new_vscode_versions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    home-manager,
    darwin,
    determinate,
    nur,
    nix-index-database,
    nvchad4nix,
    vscode-server,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin"];
      imports = [
        inputs.pre-commit-hooks.flakeModule
      ];
      flake = {
        nixosConfigurations.knownapps =
          nixpkgs.lib.nixosSystem
          {
            system = "x86_64-linux";
            modules = [
              ./nas/system
              ./nas/containers
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.thurstonsand = {
                    imports = [
                      inputs.nvchad4nix.homeManagerModule
                      nix-index-database.hmModules.nix-index
                      (import ./common/home.nix)
                      (import ./nas/home.nix)
                    ];
                  };
                };
              }
              vscode-server.nixosModules.default
              {
                services.vscode-server.enable = true;
              }
            ];
          };
        darwinConfigurations = {
          "Thurstons-MacBook-Pro" = darwin.lib.darwinSystem {
            inherit inputs;
            system = "aarch64-darwin";
            modules = [
              ./darwin/system
              home-manager.darwinModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.thurstonsand = {
                    imports = [
                      inputs.nvchad4nix.homeManagerModule
                      nix-index-database.hmModules.nix-index
                      (import ./common/home.nix)
                      (import ./darwin/home.nix)
                    ];
                  };
                };
              }
            ];
          };
        };
        homeConfigurations = {
          # TODO: may remove this if we don't use nix after all
          "truenas-shell" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
            modules = [
              nix-index-database.hmModules.nix-index
              ./common/home.nix
              ./truenas-shell/home.nix
            ];
          };
          "deck" = home-manager.lib.homeManagerConfiguration {
            modules = [
              {
                nixpkgs.overlays = [nur.overlay];
              }
              nix-index-database.hmModules.nix-index
              ./common/home.nix
              ./steamdeck/home.nix
            ];
          };
        };
      };
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        packages.default = home-manager.packages.${system}.default;
        formatter = pkgs.alejandra;
        devShells.default = pkgs.mkShell {
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
          nativeBuildInputs = with pkgs.buildPackages; [
            alejandra
            cargo
            rustc
          ];
        };
        pre-commit = {
          check.enable = true;
          settings.hooks = {
            alejandra.enable = true;
          };
        };
      };
    };
}
