#include "raylib.h"
#include <stdio.h>
#include <string.h>

#define TIMER_COUNT 3
#define WINDOW_WIDTH 220
#define WINDOW_HEIGHT 200

typedef struct {
    int duration;
    int remaining;
    bool running;
    bool finished;
    char label[16];
    Rectangle rect;
} Timer;

Timer timers[TIMER_COUNT];
Sound dingSound;
Vector2 dragOffset = {0};
bool isDragging = false;
bool soundLoaded = false;

void InitTimers() {
    Timer t1 = {60, 0, false, false, "1 min", {10, 40, 200, 40}};
    Timer t2 = {300, 0, false, false, "5 min", {10, 90, 200, 40}};
    Timer t3 = {900, 0, false, false, "15 min", {10, 140, 200, 40}};
    
    timers[0] = t1;
    timers[1] = t2;
    timers[2] = t3;
}

void UpdateTimer(Timer* timer) {
    if (timer->running && !timer->finished) {
        timer->remaining--;
        if (timer->remaining <= 0) {
            timer->finished = true;
            timer->running = false;
            if (soundLoaded) {
                PlaySound(dingSound);
            }
        }
    }
}

void DrawTimer(Timer* timer) {
    Color bgColor = DARKGRAY;
    Color fillColor = BLUE;
    
    if (timer->finished) {
        bgColor = RED;
        fillColor = (Color){139, 0, 0, 255}; // DARKRED
    } else if (timer->running) {
        bgColor = DARKBLUE;
        fillColor = LIGHTGRAY;
    }
    
    DrawRectangleRec(timer->rect, bgColor);
    
    if (timer->running && timer->remaining > 0) {
        float progress = (float)(timer->duration - timer->remaining) / timer->duration;
        Rectangle progressRect = {
            timer->rect.x,
            timer->rect.y,
            timer->rect.width * progress,
            timer->rect.height
        };
        DrawRectangleRec(progressRect, fillColor);
    }
    
    DrawRectangleLinesEx(timer->rect, 2, WHITE);
    
    char text[64];
    if (timer->running) {
        int mins = timer->remaining / 60;
        int secs = timer->remaining % 60;
        sprintf(text, "%s %d:%02d", timer->label, mins, secs);
    } else if (timer->finished) {
        sprintf(text, "%s DONE!", timer->label);
    } else {
        strcpy(text, timer->label);
    }
    
    int fontSize = 24;
    Vector2 textSize = MeasureTextEx(GetFontDefault(), text, fontSize, 1);
    Vector2 textPos = {
        timer->rect.x + (timer->rect.width - textSize.x) / 2,
        timer->rect.y + (timer->rect.height - textSize.y) / 2
    };
    
    DrawTextEx(GetFontDefault(), text, textPos, fontSize, 1, WHITE);
}

void HandleTimerClick(Timer* timer) {
    if (timer->running) {
        timer->remaining = timer->duration;
    } else {
        timer->running = true;
        timer->finished = false;
        timer->remaining = timer->duration;
    }
}

void HandleTimerRightClick(Timer* timer) {
    timer->running = false;
    timer->finished = false;
    timer->remaining = 0;
}

int main() {
    SetConfigFlags(FLAG_WINDOW_TOPMOST | FLAG_WINDOW_UNDECORATED);
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Timer App");
    SetTargetFPS(60);
    
    InitAudioDevice();
    if (FileExists("ding.wav")) {
        dingSound = LoadSound("ding.wav");
        soundLoaded = true;
    }
    
    InitTimers();
    
    while (!WindowShouldClose()) {
        Vector2 mousePos = GetMousePosition();
        
        if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
            bool clickedTimer = false;
            for (int i = 0; i < TIMER_COUNT; i++) {
                if (CheckCollisionPointRec(mousePos, timers[i].rect)) {
                    HandleTimerClick(&timers[i]);
                    clickedTimer = true;
                    break;
                }
            }
            
            if (!clickedTimer && mousePos.y < 30) {
                isDragging = true;
                dragOffset = mousePos;
            }
        }
        
        if (IsMouseButtonPressed(MOUSE_BUTTON_RIGHT)) {
            for (int i = 0; i < TIMER_COUNT; i++) {
                if (CheckCollisionPointRec(mousePos, timers[i].rect)) {
                    HandleTimerRightClick(&timers[i]);
                    break;
                }
            }
        }
        
        if (isDragging) {
            if (IsMouseButtonDown(MOUSE_BUTTON_LEFT)) {
                Vector2 delta = {mousePos.x - dragOffset.x, mousePos.y - dragOffset.y};
                Vector2 windowPos = GetWindowPosition();
                SetWindowPosition(windowPos.x + delta.x, windowPos.y + delta.y);
                dragOffset = mousePos;
            } else {
                isDragging = false;
            }
        }
        
        static int frameCounter = 0;
        frameCounter++;
        if (frameCounter >= 60) {
            frameCounter = 0;
            for (int i = 0; i < TIMER_COUNT; i++) {
                UpdateTimer(&timers[i]);
            }
        }
        
        BeginDrawing();
        ClearBackground(BLACK);
        
        DrawRectangle(0, 0, WINDOW_WIDTH, 30, GRAY);
        DrawText("Timer App", 10, 8, 16, WHITE);
        
        for (int i = 0; i < TIMER_COUNT; i++) {
            DrawTimer(&timers[i]);
        }
        
        EndDrawing();
    }
    
    if (soundLoaded) {
        UnloadSound(dingSound);
    }
    CloseAudioDevice();
    CloseWindow();
    
    return 0;
}
