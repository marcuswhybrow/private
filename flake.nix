{
  description = "Marcus' history-off Alacritty terminal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    alacritty.url = "github:marcuswhybrow/alacritty";
  };

  outputs = { self, nixpkgs, ... }@inputs: {

    packages.x86_64-linux.private = let 
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.runCommand "private" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } (let
      catppuccin = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "alacritty";
        rev = "071d73effddac392d5b9b8cd5b4b527a6cf289f9";
        sha256 = "sha256-HiIYxTlif5Lbl9BAvPsnXp8WAexL8YuohMDd/eCJVQ8=";
      };

      alacritty = inputs.alacritty.overrides.x86_64-linux.alacritty {
        import = [
          "${catppuccin}/catppuccin-mocha.toml"
        ];
      };
    in ''
      mkdir -p $out/bin
      makeWrapper \
        ${alacritty}/bin/alacritty \
        $out/bin/private \
        --add-flags "--command ${pkgs.fish}/bin/fish --private"

      mkdir -p $out/share/applications
      cat > $out/share/applications/private.desktop << EOF
      [Desktop Entry]
      Version=1.0
      Name=Private
      GenericName=Private fish shell with dark Alacritty theme
      Terminal=false
      Type=Application
      Exec=$out/bin/private
      EOF

    '');

    packages.x86_64-linux.default = self.packages.x86_64-linux.private;
  };
}
