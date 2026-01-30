#include "raylib.h"

int main(void)
{
    InitWindow(800, 600, "manual timer");

    double lastTime = GetTime();
    float pos = 0.0f;
    
    while (!WindowShouldClose())
    {
        double now = GetTime();
        float delta = (float)(now - lastTime);
        lastTime = now;

        PollInputEvents();
        if (IsKeyDown(KEY_SPACE))
            pos += delta * 100.0f;

        BeginDrawing();
            ClearBackground(WHITE);
            DrawCircle((int)pos, 100, 10, RED);
        EndDrawing();

        SwapScreenBuffer();

        double nextFrame = now + 1.0 / 60.0;
        double currentTime = GetTime();
        float wait = (float)(nextFrame - currentTime);
        if (wait > 0.0f)
            WaitTime(wait);
    }

    CloseWindow();
    return 0;
}
