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

string(TOLOWER ${IMGUI_PLATFORM} IMGUI_PLATFORM_LOWER)
if(${IMGUI_PLATFORM_LOWER} STREQUAL "win32")
    message(STATUS "[ImGui] Including backend platform: [WIN32]")
    list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_win32.h)
    list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_win32.cpp)
else ()
    message(FATAL_ERROR "[ImGui] ${IMGUI_PLATFORM} Currently Not Support!")
endif()

if (IMGUI_BACKEND_DX9)
    message(STATUS "[ImGui] Including backend api: [Direct3D9]")
    list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx9.h)
    list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx9.cpp)
    list(APPEND IMGUI_SOURCE_FILES ${Y_SOURCE_ENTRY_DIR}/main_dx9.cpp)
    list(APPEND IMGUI_INTERFACE_LIBS d3d9)
elseif(IMGUI_BACKEND_DX10)
    message(STATUS "[ImGui] Including backend api: [Direct3D10]")
    list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx10.h)
    list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx10.cpp)
    list(APPEND IMGUI_SOURCE_FILES ${Y_SOURCE_ENTRY_DIR}/main_dx10.cpp)
    list(APPEND IMGUI_INTERFACE_LIBS d3d10)
elseif(IMGUI_BACKEND_DX11)
    message(STATUS "[ImGui] Including backend api: [Direct3D11]")
    list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx11.h)
    list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx11.cpp)
    list(APPEND IMGUI_SOURCE_FILES ${Y_SOURCE_ENTRY_DIR}/main_dx11.cpp)
    list(APPEND IMGUI_INTERFACE_LIBS d3d11)
elseif (IMGUI_BACKEND_DX12)
    message(STATUS "[ImGui] Including backend api: [Direct3D12]")
    list(APPEND IMGUI_HEAD_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx12.h)
    list(APPEND IMGUI_SOURCE_FILES ${IMGUI_BACKENDS_DIR}/imgui_impl_dx12.cpp)
    list(APPEND IMGUI_SOURCE_FILES ${Y_SOURCE_ENTRY_DIR}/main_dx12.cpp)
    list(APPEND IMGUI_INTERFACE_LIBS d3d12 dxgi d3dcompiler)
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

target_compile_options(${PROJECT_NAME}
        PUBLIC
        $<$<CXX_COMPILER_ID:MSVC>:$<$<CONFIG:Debug>:/MDd>>
        $<$<CXX_COMPILER_ID:MSVC>:$<$<CONFIG:MinSizeRel>:/MD>>
        $<$<CXX_COMPILER_ID:MSVC>:$<$<CONFIG:Release>:/MD>>
        $<$<CXX_COMPILER_ID:MSVC>:$<$<CONFIG:RelWithDebInfo>:/MDd>>
)
