{
  description = "Marcus' history-off Alacritty terminal";

  inputs = {
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
        rev = "3c808cbb4f9c87be43ba5241bc57373c793d2f17";
        sha256 = "sha256-w9XVtEe7TqzxxGUCDUR9BFkzLZjG8XrplXJ3lX6f+x0=";
      };

      alacritty = inputs.alacritty.overrides.x86_64-linux.alacritty {
        import = [
          "${catppuccin}/catppuccin-mocha.yml"
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
