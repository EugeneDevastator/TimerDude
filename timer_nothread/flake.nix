{
  description = "TimerDude with custom raylib - Windows build";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Windows cross-compilation toolchain
        mingw = pkgs.pkgsCross.mingwW64;
        
        # Custom raylib for Windows with frame control
        raylib-windows = mingw.raylib.overrideAttrs (oldAttrs: {
          pname = "raylib-windows-custom";
          cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [
            "-DSUPPORT_CUSTOM_FRAME_CONTROL=ON"
            "-DPLATFORM=Desktop"
          ];
        });
        
        # Windows build script
        build-windows = pkgs.writeShellScriptBin "build-windows" ''
          echo "Building TimerDude for Windows..."
          ${mingw.stdenv.cc}/bin/${mingw.stdenv.cc.targetPrefix}gcc \
            -O2 -Wall -Wno-missing-braces \
            -I${raylib-windows}/include \
            timer.c \
            -L${raylib-windows}/lib \
            -lraylib -lopengl32 -lgdi32 -lwinmm \
            -o timer.exe
          echo "Windows build complete! timer.exe ready"
        '';
        
        # Linux build script (for testing)
        build-linux = pkgs.writeShellScriptBin "build-linux" ''
          echo "Building TimerDude for Linux..."
          gcc -O2 -Wall -Wno-missing-braces \
            timer.c \
            $(pkg-config --cflags --libs raylib) \
            -o timer
          echo "Linux build complete!"
        '';
        
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.gcc
            pkgs.pkg-config
            mingw.stdenv.cc
            raylib-windows
            build-windows
            build-linux
          ];
          
          shellHook = ''
            echo "=== TimerDude Cross-Compilation Environment ==="
            echo "Raylib with SUPPORT_CUSTOM_FRAME_CONTROL enabled"
            echo ""
            echo "Commands:"
            echo "  build-windows  - Build timer.exe for Windows"
            echo "  build-linux    - Build timer for Linux (testing)"
            echo ""
            echo "Target: ${mingw.stdenv.cc.targetPrefix}"
          '';
        };
        
        # Windows package
        packages.windows = mingw.stdenv.mkDerivation {
          pname = "timer-dude-windows";
          version = "1.0.0";
          
          src = ./.;
          
          buildInputs = [ raylib-windows ];
          
          buildPhase = ''
            ${mingw.stdenv.cc}/bin/${mingw.stdenv.cc.targetPrefix}gcc \
              -O2 -Wall -Wno-missing-braces \
              -I${raylib-windows}/include \
              timer.c \
              -L${raylib-windows}/lib \
              -lraylib -lopengl32 -lgdi32 -lwinmm \
              -o timer.exe
          '';
          
          installPhase = ''
            mkdir -p $out/bin
            cp timer.exe $out/bin/
          '';
        };
        
        packages.default = self.packages.${system}.windows;
      });
}
