#include "backend/backend.h"
#include "context/imgui_context.h"

#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN 1
#include <windows.h>
int main(int argv, char **);
int CALLBACK WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    return main(__argc, __argv);
}
#endif

void DrawFrame(Backend *backend);

int main(int argc, char *argv[]) {
    AppImGuiContext app_context;

    Backend backend("imgui_cmake");
    backend.setup([&backend]() { DrawFrame(&backend); });

    backend.show();
    backend.run();

    return 0;
}

bool show_demo_window = true;

void DrawFrame(Backend *backend) {
    int display_w, display_h;
    backend->new_frame(display_w, display_h);
    ImGui::NewFrame();
    ImGui::ShowDemoWindow(&show_demo_window);

    backend->end_frame();
}
