project(ImGui)

set(IMGUI_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/imgui)
set(IMGUI_BACKENDS_DIR ${IMGUI_SOURCE_DIR}/backends)

set(IMGUI_HEAD_FILES
        ${IMGUI_SOURCE_DIR}/imgui.h
        ${IMGUI_SOURCE_DIR}/imconfig.h
        ${IMGUI_SOURCE_DIR}/imgui_internal.h
        ${IMGUI_SOURCE_DIR}/imstb_rectpack.h
        ${IMGUI_SOURCE_DIR}/imstb_textedit.h
        ${IMGUI_SOURCE_DIR}/imstb_truetype.h
)

set(IMGUI_SOURCE_FILES
        ${IMGUI_SOURCE_DIR}/imgui.cpp
        ${IMGUI_SOURCE_DIR}/imgui_demo.cpp
        ${IMGUI_SOURCE_DIR}/imgui_draw.cpp
        ${IMGUI_SOURCE_DIR}/imgui_tables.cpp
        ${IMGUI_SOURCE_DIR}/imgui_widgets.cpp
)

# set(IMGUI_FONTS_FILES ${IMGUI_SOURCE_DIR}/misc/fonts/*.ttf)
set(IMGUI_FONTS_FILES)

if (IMGUI_PLATFORM_WIN32)
    message(STATUS "[ImGui] Including backend platform: [WIN32]")
    list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_win32.h)
    list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_win32.cpp)

    if (IMGUI_BACKEND_DX9)
        message(STATUS "[ImGui] Including backend api: [Direct3D9]")
        list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx9.h)
        list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx9.cpp)
        list(APPEND IMGUI_SOURCE_FILES ${Y_SOURCE_ENTRY_DIR}/main_win32_dx9.cpp)
        list(APPEND IMGUI_INTERFACE_LIBS d3d9)
    elseif (IMGUI_BACKEND_DX10)
        message(STATUS "[ImGui] Including backend api: [Direct3D10]")
        list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx10.h)
        list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx10.cpp)
        list(APPEND IMGUI_SOURCE_FILES ${Y_SOURCE_ENTRY_DIR}/main_win32_dx10.cpp)
        list(APPEND IMGUI_INTERFACE_LIBS d3d10)
    elseif (IMGUI_BACKEND_DX11)
        message(STATUS "[ImGui] Including backend api: [Direct3D11]")
        list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx11.h)
        list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx11.cpp)
        list(APPEND IMGUI_SOURCE_FILES ${Y_SOURCE_ENTRY_DIR}/main_win32_dx11.cpp)
        list(APPEND IMGUI_INTERFACE_LIBS d3d11)
    elseif (IMGUI_BACKEND_DX12)
        message(STATUS "[ImGui] Including backend api: [Direct3D12]")
        list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx12.h)
        list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx12.cpp)
        list(APPEND IMGUI_SOURCE_FILES ${Y_SOURCE_ENTRY_DIR}/main_win32_dx12.cpp)
        list(APPEND IMGUI_INTERFACE_LIBS d3d12 dxgi d3dcompiler)
    endif ()

elseif (IMGUI_PLATFORM_GLFW)
    message(STATUS "[ImGui] Including backend platform: [GLFW]")

    set(GLFW_BUILD_DOCS OFF)
    set(GLFW_INSTALL OFF)
    add_subdirectory(glfw)
    list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_glfw.h)
    list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_glfw.cpp)

    if (IMGUI_BACKEND_OPENGL2)
        message(STATUS "[ImGui] Including backend api: [OpenGL2]")
        list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_opengl2.h)
        list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_opengl2.cpp)
        list(APPEND IMGUI_SOURCE_FILES ${Y_SOURCE_ENTRY_DIR}/main_glfw_opengl2.cpp)
        list(APPEND IMGUI_INTERFACE_LIBS opengl32 glfw)
    elseif (IMGUI_BACKEND_OPENGL3)
        message(STATUS "[ImGui] Including backend api: [OpenGL3]")
        list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_opengl3.h)
        list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_opengl3.cpp)
        list(APPEND IMGUI_SOURCE_FILES ${Y_SOURCE_ENTRY_DIR}/main_glfw_opengl3.cpp)
        list(APPEND IMGUI_INTERFACE_LIBS opengl32 glfw)
    elseif (IMGUI_BACKEND_VULKAN)
        # message(STATUS "[ImGui] Including backend api: [Vulkan]")
        # list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_vulkan.h)
        # list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_vulkan.cpp)
        # list(APPEND IMGUI_SOURCE_FILES ${Y_SOURCE_ENTRY_DIR}/main_glfw_opengl3.cpp)
    endif ()

    list(APPEND IMGUI_INTERFACE_INCLUDES "${CMAKE_CURRENT_LIST_DIR}/glfw/include")
else ()
    message(FATAL_ERROR "[ImGui] Current Platform Not Support!")
endif ()

set(IMGUI_FILES
        ${IMGUI_HEAD_FILES}
        ${IMGUI_SOURCE_FILES}
        ${IMGUI_FONTS_FILES}
)

add_library(${PROJECT_NAME} STATIC ${IMGUI_FILES})
add_library(ImGui::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
        PUBLIC
        $<BUILD_INTERFACE:${IMGUI_SOURCE_DIR}>
        $<BUILD_INTERFACE:${IMGUI_BACKENDS_DIR}>
)

target_link_libraries(${PROJECT_NAME} INTERFACE ${IMGUI_INTERFACE_LIBS})
if (DEFINED IMGUI_INTERFACE_INCLUDES AND NOT "${IMGUI_INTERFACE_INCLUDES}" STREQUAL "")
    target_include_directories(${PROJECT_NAME} PRIVATE ${IMGUI_INTERFACE_INCLUDES})
endif ()

target_compile_options(${PROJECT_NAME}
        PUBLIC
        $<$<CXX_COMPILER_ID:MSVC>:$<$<CONFIG:Debug>:/MDd>>
        $<$<CXX_COMPILER_ID:MSVC>:$<$<CONFIG:MinSizeRel>:/MD>>
        $<$<CXX_COMPILER_ID:MSVC>:$<$<CONFIG:Release>:/MD>>
        $<$<CXX_COMPILER_ID:MSVC>:$<$<CONFIG:RelWithDebInfo>:/MD>>
)
