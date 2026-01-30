#!/bin/bash
set -e

echo "Building TimerDude..."

# Check if in Nix shell
if [ -n "$IN_NIX_SHELL" ]; then
    echo "Using Nix environment"
    build-timer
else
    echo "Using system tools (fallback)"
    
    # Download raylib if needed
    if [ ! -d "raylib" ]; then
        echo "Downloading raylib..."
        curl -L https://github.com/raysan5/raylib/archive/refs/tags/5.0.tar.gz | tar xz
        mv raylib-5.0 raylib
    fi
    
    # Compile raylib objects
    echo "Compiling raylib..."
    gcc -O2 -DSUPPORT_CUSTOM_FRAME_CONTROL=1 -c raylib/src/*.c
    
    # Compile timer
    echo "Compiling timer..."
    gcc -O2 -Wall timer.c *.o -lopengl32 -lgdi32 -lwinmm -o timer
    
    # Cleanup
    rm -f *.o
fi

echo "Build complete!"
