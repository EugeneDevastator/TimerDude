@echo off
setlocal enabledelayedexpansion

echo Building TimerDude with custom raylib...

:: Check if raylib exists
if not exist "raylib" (
    echo Downloading raylib...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/raysan5/raylib/archive/refs/tags/5.0.zip' -OutFile 'raylib.zip'"
    
    echo Extracting raylib...
    powershell -Command "Expand-Archive -Path 'raylib.zip' -DestinationPath '.'"
    ren raylib-5.0 raylib
    del raylib.zip
)

:: Compile raylib with custom flag
echo Compiling raylib...
gcc -O2 -Wall -Wno-missing-braces -DSUPPORT_CUSTOM_FRAME_CONTROL=1 -c raylib/src/rcore.c -o rcore.o
gcc -O2 -Wall -Wno-missing-braces -DSUPPORT_CUSTOM_FRAME_CONTROL=1 -c raylib/src/rshapes.c -o rshapes.o
gcc -O2 -Wall -Wno-missing-braces -DSUPPORT_CUSTOM_FRAME_CONTROL=1 -c raylib/src/rtextures.c -o rtextures.o
gcc -O2 -Wall -Wno-missing-braces -DSUPPORT_CUSTOM_FRAME_CONTROL=1 -c raylib/src/rtext.c -o rtext.o
gcc -O2 -Wall -Wno-missing-braces -DSUPPORT_CUSTOM_FRAME_CONTROL=1 -c raylib/src/rmodels.c -o rmodels.o
gcc -O2 -Wall -Wno-missing-braces -DSUPPORT_CUSTOM_FRAME_CONTROL=1 -c raylib/src/utils.c -o utils.o
gcc -O2 -Wall -Wno-missing-braces -DSUPPORT_CUSTOM_FRAME_CONTROL=1 -c raylib/src/raudio.c -o raudio.o
gcc -O2 -Wall -Wno-missing-braces -DSUPPORT_CUSTOM_FRAME_CONTROL=1 -c raylib/src/rglfw.c -o rglfw.o

:: Compile timer
echo Compiling timer...
gcc -O2 -Wall timer.c rcore.o rshapes.o rtextures.o rtext.o rmodels.o utils.o raudio.o rglfw.o -lopengl32 -lgdi32 -lwinmm -o timer.exe

:: Cleanup
del *.o

echo Build complete! Run timer.exe
pause
