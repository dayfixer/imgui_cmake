#pragma once

class WindowPosition {
public:
    WindowPosition();

    int x;
    int y;
    int width;
    int height;
    bool maximize{false};
    bool iconified{false};

    // Not used
    bool fullscreen;
    bool borderless;
    bool resizable;
    bool visible;
    bool topmost;
    bool focus;
    bool focus_on_show;
    bool always_on_top;
};
