{
  description = "Rust coin";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = { url = "github:nix-community/fenix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, flake-utils, fenix } @ inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ fenix.overlays.default ];
          pkgs = import nixpkgs { inherit overlays system; };
          toolchain = pkgs.fenix.complete;
          libraries = with pkgs;[
            pkg-config
          ];
          packages = with pkgs; [
            curl
            wget
            pkg-config
            dbus
            openssl_3
            glib
            gtk3
            libsoup
            webkitgtk_4_1
            appimagekit
            librsvg

            # rust: https://github.com/the-nix-way/dev-templates/blob/main/rust/flake.nix
            # rustToolchain # The package provided by our custom overlay. Includes cargo, Clippy, cargo-fmt, rustdoc, rustfmt, and other tools.
            # openssl
            systemd
            cargo-deny
            cargo-edit
            cargo-watch
            rust-analyzer
            (with toolchain; [
              cargo
              rustc
              rust-src
              clippy
              rustfmt
            ])
            yarn
          ];
        in
        {
          devShell = pkgs.mkShell {
            buildInputs = packages;
            RUST_BACKTRACE = "full";
            RUST_SRC_PATH = "${toolchain.rust-src}/lib/rustlib/src/rust/library"; # for better in-editor support
            shellHook =
              ''
                export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH
                export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS
                RUST_BACKTRACE=full
                # Fix blank screen on nvidia drivers (https://github.com/tauri-apps/tauri/issues/4315#issuecomment-1207755694)
                export WEBKIT_DISABLE_COMPOSITING_MODE=1
                # Allows us to register global shortcuts on wayland
                # GDK_BACKEND=x11
              '';
          };
        });
}
