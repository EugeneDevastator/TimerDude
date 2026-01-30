CC = gcc
CFLAGS = -O2 -Wall -Wno-missing-braces
RAYLIB_FLAGS = -DSUPPORT_CUSTOM_FRAME_CONTROL=1
LIBS = -lopengl32 -lgdi32 -lwinmm

# Raylib source (download raylib source and extract to raylib/ folder)
RAYLIB_SRC = raylib/src
RAYLIB_OBJS = $(RAYLIB_SRC)/rcore.o $(RAYLIB_SRC)/rshapes.o $(RAYLIB_SRC)/rtextures.o \
              $(RAYLIB_SRC)/rtext.o $(RAYLIB_SRC)/rmodels.o $(RAYLIB_SRC)/utils.o \
              $(RAYLIB_SRC)/raudio.o $(RAYLIB_SRC)/rglfw.o

all: timer.exe

# Build raylib objects with custom flag
$(RAYLIB_SRC)/%.o: $(RAYLIB_SRC)/%.c
	$(CC) $(CFLAGS) $(RAYLIB_FLAGS) -c $< -o $@

# Build timer
timer.exe: timer.c $(RAYLIB_OBJS)
	$(CC) $(CFLAGS) timer.c $(RAYLIB_OBJS) -o timer.exe $(LIBS)

clean:
	del /Q $(RAYLIB_SRC)\*.o timer.exe

.PHONY: all clean
