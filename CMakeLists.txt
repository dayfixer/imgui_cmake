cmake_minimum_required(VERSION 3.10)

project(Demo)

set(Y_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(Y_SOURCE_ENTRY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/entry")

# Default Win32
set(IMGUI_PLATFORM "Win32")
# Default DX9
option(IMGUI_BACKEND_DX9 "[ImGui] Backend by [Direct3D9]" OFF)
option(IMGUI_BACKEND_DX10 "[ImGui] Backend by [Direct3D10]" OFF)
option(IMGUI_BACKEND_DX11 "[ImGui] Backend by [Direct3D11]" ON)
option(IMGUI_BACKEND_DX12 "[ImGui] Backend by [Direct3D12]" OFF)

include(${CMAKE_CURRENT_SOURCE_DIR}/ImGui.cmake)

add_executable(Demo
        ${Y_SOURCE_DIR}/MainWindow.h
        ${Y_SOURCE_DIR}/MainWindow.cpp
)
target_link_libraries(Demo PRIVATE ImGui::ImGui)