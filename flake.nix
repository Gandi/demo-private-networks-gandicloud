{
  description = "Nix Shell to deploy using OpenTofu";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";


  outputs = { self, nixpkgs }: {
    devShell.x86_64-linux = let
      tfoverlay = final: prev: {
        terraform-providers = prev.terraform-providers // {
          gandi = prev.terraform-providers.gandi.override {
            rev = "c38a15f10015d5d14a8982ca334709e241092a93";
            version = "2.3.0";
            hash = "sha256-fsCtmwyxkXfOtiZG27VEb010jglK35yr4EynnUWlFog";
            vendorHash = "sha256-EiTWJ4bw8IwsRTD9Lt28Up2DXH0oVneO2IaO8VqWtkw=";
          };
        };
      };
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ tfoverlay ];
      };
    in pkgs.mkShell {
      buildInputs = [
        (pkgs.opentofu.withPlugins (p: [ p.openstack p.gandi p.random ]))
        pkgs.asciinema
      ];
    };
  };
}
