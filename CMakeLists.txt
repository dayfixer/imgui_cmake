cmake_minimum_required(VERSION 3.10)

project(Demo)

include(cmake/HelperFunction.cmake)

# Default GLFW
option(IMGUI_PLATFORM_WIN32 "Use Win32 backend for GLFW" OFF)
option(IMGUI_PLATFORM_GLFW "Use GLFW backend for GLFW" ON)

if (IMGUI_PLATFORM_WIN32)
    set_mutex_option(IMGUI_PLATFORM_WIN32 IMGUI_PLATFORM_GLFW)
elseif (IMGUI_PLATFORM_GLFW)
    set_mutex_option(IMGUI_PLATFORM_GLFW IMGUI_PLATFORM_WIN32)
endif ()

if (IMGUI_PLATFORM_WIN32)
    option(IMGUI_BACKEND_DX9 "[ImGui] Backend by [Direct3D9]" OFF)
    option(IMGUI_BACKEND_DX10 "[ImGui] Backend by [Direct3D10]" OFF)
    option(IMGUI_BACKEND_DX11 "[ImGui] Backend by [Direct3D11]" ON)
    option(IMGUI_BACKEND_DX12 "[ImGui] Backend by [Direct3D12]" OFF)

    if (IMGUI_BACKEND_DX9)
        set_mutex_option(IMGUI_BACKEND_DX9 IMGUI_BACKEND_DX10 IMGUI_BACKEND_DX11 IMGUI_BACKEND_DX12)
    elseif (IMGUI_BACKEND_DX10)
        set_mutex_option(IMGUI_BACKEND_DX10 IMGUI_BACKEND_DX9 IMGUI_BACKEND_DX11 IMGUI_BACKEND_DX12)
    elseif (IMGUI_BACKEND_DX11)
        set_mutex_option(IMGUI_BACKEND_DX11 IMGUI_BACKEND_DX9 IMGUI_BACKEND_DX10 IMGUI_BACKEND_DX12)
    elseif (IMGUI_BACKEND_DX12)
        set_mutex_option(IMGUI_BACKEND_DX12 IMGUI_BACKEND_DX9 IMGUI_BACKEND_DX10 IMGUI_BACKEND_DX11)
    endif ()

elseif (IMGUI_PLATFORM_GLFW)
    option(IMGUI_BACKEND_OPENGL2 "[ImGui] Backend by [OpenGL2]" OFF)
    option(IMGUI_BACKEND_OPENGL3 "[ImGui] Backend by [OpenGL3]" ON)
    option(IMGUI_BACKEND_VULKAN "[ImGui] Backend by [Vulkan]" OFF)

    if (IMGUI_BACKEND_OPENGL2)
        set_mutex_option(IMGUI_BACKEND_OPENGL2 IMGUI_BACKEND_OPENGL3 IMGUI_BACKEND_VULKAN)
    elseif (IMGUI_BACKEND_OPENGL3)
        set_mutex_option(IMGUI_BACKEND_OPENGL3 IMGUI_BACKEND_OPENGL2 IMGUI_BACKEND_VULKAN)
    elseif (IMGUI_BACKEND_VULKAN)
        set_mutex_option(IMGUI_BACKEND_VULKAN IMGUI_BACKEND_OPENGL2 IMGUI_BACKEND_OPENGL3)
    endif ()

endif ()

message(STATUS "[Platform]:")
message(STATUS "   Win32? ${IMGUI_PLATFORM_WIN32}")
message(STATUS "   GLFW ? ${IMGUI_PLATFORM_GLFW}")

set(Y_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

# Y_BACKEND_DIR used by ImGui.cmake
set(Y_BACKEND_DIR "${Y_SOURCE_DIR}/backend")
include(cmake/ImGui.cmake)

if (WIN32)
    set(Y_PLATFORM_EXE_TAG "WIN32")
endif ()

add_executable(Demo WIN32
        ${Y_SOURCE_DIR}/backend/window_position.h
        ${Y_SOURCE_DIR}/backend/window_position.cpp
        ${Y_SOURCE_DIR}/context/imgui_context.h
        ${Y_SOURCE_DIR}/context/imgui_context.cpp
        ${Y_SOURCE_DIR}/main.cpp
)
target_link_libraries(Demo PRIVATE ImGui::ImGui)
target_include_directories(Demo PRIVATE ${Y_SOURCE_DIR})