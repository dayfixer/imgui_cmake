#include "backend/backend.h"
#include "context/imgui_context.h"

#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN 1
#include <windows.h>
int main(int argc, char *argv[]);
int CALLBACK WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    return main(__argc, __argv);
}
#endif

int DrawFrame(Backend *backend);

int main(int argc, char *argv[]) {
    AppImGuiContext app_context;
    Backend backend("imgui_cmake");
    backend.setup([&backend]() -> int { return DrawFrame(&backend); });

    // Open this if you want to show a black window on windows
    // backend.show();
    backend.run();

    return 0;
}

bool s_show = true;

int DrawFrame(Backend *backend) {
    int display_w, display_h;
    backend->new_frame(display_w, display_h);
    ImGui::NewFrame();

    ImGui::ShowDemoWindow(nullptr);

    ImGuiWindowFlags window_flags = 0;
    window_flags |= ImGuiWindowFlags_NoCollapse;

    ImGui::Begin("Dear ImGui Demo2", &s_show, window_flags);
    if (ImGui::Button("Hello")) {
        ImGui::Text("Hello, world!");
    }
    ImGui::End();

    backend->end_frame();
    return s_show ? 0 : -1;
}
