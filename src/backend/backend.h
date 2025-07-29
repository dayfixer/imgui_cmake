#pragma once

#include <cstdint>
#include <functional>
#include <string>

class Backend {
public:
    Backend(const char *title);

    ~Backend();

    void set_title(const char *title);

    void set_icon(int w, int h, unsigned char *data);

    bool setup(const std::function<void()> &paint, int w = 1280, int h = 720);

    void show();

    void run();

    void start_frame(int &w, int &h);

    void end_frame();

private:
    bool valid_{false};
    const char *title_;
};
