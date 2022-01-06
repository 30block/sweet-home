{
  description = "Home configuration";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/release-21.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";

      # We want home-manager to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    local = {
      home = inputs.home-manager.lib.homeManagerConfiguration {
        system = "aarch64-linux";
        homeDirectory = "/home/me";
        username = "me";
        configuration.imports = [ ./home.nix ];
      };
    };
  };
}
