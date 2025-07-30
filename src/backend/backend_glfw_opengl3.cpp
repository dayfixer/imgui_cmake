#include "backend.h"

#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"

#include <stdio.h>
#include <stdlib.h>

#define GL_SILENCE_DEPRECATION
#if defined(IMGUI_IMPL_OPENGL_ES2)
#include <GLES2/gl2.h>
#endif
#include <GLFW/glfw3.h> // Will drag system OpenGL headers

static GLFWwindow *s_window;
static std::function<int()> s_paint;
static float s_prev_scale = 1.0f;

static WindowPosition *s_p_win_pos;

static void glfw_error_callback(int error, const char *description) {
    fprintf(stderr, "GLFW Error %d: %s\n", error, description);
}

static void glfw_window_pos_callback(GLFWwindow *window, int x, int y) {
    if (!glfwGetWindowAttrib(window, GLFW_MAXIMIZED)) {
        s_p_win_pos->x = x;
        s_p_win_pos->y = y;
    }
}

static void glfw_window_size_callback(GLFWwindow *window, int w, int h) {
    if (!glfwGetWindowAttrib(window, GLFW_MAXIMIZED)) {
        s_p_win_pos->width = w;
        s_p_win_pos->height = h;
    }
}

static void glfw_window_maximize_callback(GLFWwindow *, int maximized) {
    s_p_win_pos->maximize = maximized;
}

static void glfw_window_iconify_callback(GLFWwindow *, int iconified) {
    s_p_win_pos->iconified = iconified != 0;
}

Backend::Backend(const char *title) : title_(title), width_(0), height_(0) {
    s_p_win_pos = &win_pos_;
}

Backend::~Backend() {
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();

    if (s_window)
        glfwDestroyWindow(s_window);
    glfwTerminate();
}

void Backend::set_title(const char *title) {
    glfwSetWindowTitle(s_window, title);
}

void Backend::set_icon(int w, int h, unsigned char *data) {
    GLFWimage icon;
    icon.width = w;
    icon.height = h;
    icon.pixels = data;
    glfwSetWindowIcon(s_window, 1, &icon);
}

void Backend::setup(const PaintFunction &paint, int w, int h) {
    glfwSetErrorCallback(glfw_error_callback);
    if (!glfwInit())
        exit(1);

    // Decide GL+GLSL versions
#if defined(IMGUI_IMPL_OPENGL_ES2)
    // GL ES 2.0 + GLSL 100 (WebGL 1.0)
    const char *glsl_version = "#version 100";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API);
#elif defined(IMGUI_IMPL_OPENGL_ES3)
    // GL ES 3.0 + GLSL 300 es (WebGL 2.0)
    const char *glsl_version = "#version 300 es";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API);
#elif defined(__APPLE__)
    // GL 3.2 + GLSL 150
    const char *glsl_version = "#version 150";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE); // 3.2+ only
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // Required on Mac
#else
    // GL 3.0 + GLSL 130
    const char *glsl_version = "#version 130";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    // glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE); // 3.2+ only
    // glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // 3.0+ only
#endif

    // Hide a black window on windows
#ifdef _WIN32
    glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
#endif

    // Create a window with graphics context
#if (GLFW_VERSION_MAJOR == 3 && GLFW_VERSION_MINOR >= 3)
    float main_scale = ImGui_ImplGlfw_GetContentScaleForMonitor(glfwGetPrimaryMonitor()); // Valid on GLFW 3.3+ only
#else
    float main_scale = 1.0f;
#endif
    s_window = glfwCreateWindow(static_cast<int>(main_scale * win_pos_.width),
                                static_cast<int>(main_scale * win_pos_.height), title_, nullptr, nullptr);
    if (s_window == nullptr)
        exit(1);

    glfwSetWindowPos(s_window, win_pos_.x, win_pos_.y);
#if GLFW_VERSION_MAJOR > 3 || (GLFW_VERSION_MAJOR == 3 && GLFW_VERSION_MINOR >= 2)
    if (win_pos_.maximize)
        glfwMaximizeWindow(s_window);
#endif

    glfwMakeContextCurrent(s_window);
    glfwSwapInterval(1); // Enable vsync

    // Setup scaling
    ImGuiStyle &style = ImGui::GetStyle();
    style.ScaleAllSizes(main_scale); // Bake a fixed style scale. (until we have a solution for dynamic style scaling,
                                     // changing this requires resetting Style + calling this again)
    style.FontScaleDpi = main_scale; // Set initial font scale. (using io.ConfigDpiScaleFonts=true makes this
                                     // unnecessary. We leave both here for documentation purpose)
#if GLFW_VERSION_MAJOR >= 3 && GLFW_VERSION_MINOR >= 3
    ImGuiIO &io = ImGui::GetIO();
    io.ConfigDpiScaleFonts = true; // [Experimental] Automatically overwrite style.FontScaleDpi in Begin() when Monitor
                                   // DPI changes. This will scale fonts but _NOT_ scale sizes/padding for now.
    io.ConfigDpiScaleViewports = true; // [Experimental] Scale Dear ImGui and Platform Windows when Monitor DPI changes.
#endif

    // Setup Platform/Renderer backends
    ImGui_ImplGlfw_InitForOpenGL(s_window, true);
    ImGui_ImplOpenGL3_Init(glsl_version);

    s_paint = paint;

#if GLFW_VERSION_MAJOR > 3 || (GLFW_VERSION_MAJOR == 3 && GLFW_VERSION_MINOR >= 3)
    glfwSetWindowMaximizeCallback(s_window, glfw_window_maximize_callback);
#endif
    glfwSetWindowIconifyCallback(s_window, glfw_window_iconify_callback);

    glfwSetWindowPosCallback(s_window, glfw_window_pos_callback);
    glfwSetWindowSizeCallback(s_window, glfw_window_size_callback);
}

void Backend::show() {
    glfwShowWindow(s_window);
}

void Backend::run() {
    while (!glfwWindowShouldClose(s_window)) {
        glfwPollEvents();

        if (glfwGetWindowAttrib(s_window, GLFW_ICONIFIED) != 0) {
            ImGui_ImplGlfw_Sleep(10);
            continue;
        }

        const int ret = s_paint();
        if (ret < 0) {
            break;
        }
    }
}

void Backend::new_frame(int &w, int &h) {
    const auto scale = get_dpi_scale();
    if (scale != s_prev_scale) {
        s_prev_scale = scale;
        // s_scaleChanged( scale );
    }

    glfwGetFramebufferSize(s_window, &w, &h);
#if defined(__APPLE__)
    w = static_cast<int>(w / scale);
    h = static_cast<int>(h / scale);
#endif
    width_ = w;
    height_ = h;

    // Start the Dear ImGui frame
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
}

void Backend::end_frame() {
    ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);

    ImGui::Render();

    glViewport(0, 0, width_, height_);
    glClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w,
                 clear_color.w);
    glClear(GL_COLOR_BUFFER_BIT);
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

    // Update and Render additional Platform Windows
    // (Platform functions may change the current OpenGL context, so we save/restore it to make it easier to paste this
    // code elsewhere.
    //  For this specific demo app we could also call glfwMakeContextCurrent(window) directly)
    ImGuiIO &io = ImGui::GetIO();
    if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
        GLFWwindow *backup_current_context = glfwGetCurrentContext();
        ImGui::UpdatePlatformWindows();
        ImGui::RenderPlatformWindowsDefault();
        glfwMakeContextCurrent(backup_current_context);
    }

    glfwSwapBuffers(s_window);
}

float Backend::get_dpi_scale() {
#if GLFW_VERSION_MAJOR > 3 || (GLFW_VERSION_MAJOR == 3 && GLFW_VERSION_MINOR >= 3)
    float x, y;
    glfwGetWindowContentScale(s_window, &x, &y);
    return x;
#else
    return 1;
#endif
}
