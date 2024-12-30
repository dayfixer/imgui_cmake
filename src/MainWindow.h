#pragma once

#include "imgui.h"

#ifdef _WIN32
#define Y_WIN_TITLE L"Demo"
#endif

class MainWindow {
public:
    MainWindow();

    ~MainWindow();

    ImVec4 GetClearColor() const;

    bool Render();

private:
    void ShowFullWindow();

private:
    // Our state
    bool opening_{true};
    bool show_demo_window{false};
    bool show_another_window{false};
    ImVec4 clear_color = ImVec4(0.f, 0.f, 0.0f, 1.00f);
};
