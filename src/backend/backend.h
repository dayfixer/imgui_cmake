#pragma once

#include "window_position.h"

#include <cstdint>
#include <functional>
#include <string>

class Backend {
public:
    using PaintFunction = std::function<int()>;

    explicit Backend(const char *title);

    ~Backend();

    void set_title(const char *title);

    void set_icon(int w, int h, unsigned char *data);

    void setup(const PaintFunction &paint, int w = 1280, int h = 720);

    void show();

    void run();

    void new_frame(int &w, int &h);

    void end_frame();

    // Get
    float get_dpi_scale();

private:
    const char *title_;
    WindowPosition win_pos_;
    int width_, height_;
};
