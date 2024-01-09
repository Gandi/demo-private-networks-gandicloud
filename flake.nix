{
  description = "Nix Shell to deploy using OpenTofu";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";


  outputs = { self, nixpkgs }: {
    devShell.x86_64-linux =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in pkgs.mkShell {
        buildInputs = [
          (pkgs.opentofu.withPlugins (p: [
            p.openstack p.gandi p.random
          ]))
          pkgs.asciinema
        ];
      };
  };
}
