cmake_minimum_required(VERSION 3.16)
project(audioBackend C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(PIPEWIRE REQUIRED IMPORTED_TARGET libpipewire-0.3 libspa-0.2)

file(GLOB AUDIO_SRC
    "input/*.c"
    "output/*.c"
    "main.c"
	"cavacore.c"
)

add_executable(audio-backend ${AUDIO_SRC})

target_link_libraries(audio-backend PRIVATE
    fftw3
    m
    PkgConfig::PIPEWIRE
)

