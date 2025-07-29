cmake_minimum_required(VERSION 3.6 FATAL_ERROR)

SET(projectName codech)
find_package(Threads)

add_library(
        codec_lib
        src/codec.c
        src/codec.h
)
add_library(
        matrix_lib
        src/matrix.c
        src/matrix.h
)
add_library(
        workers_lib
        src/workers.c
        src/workers.h
)
target_link_libraries(workers_lib codec_lib)
target_link_libraries(workers_lib ${CMAKE_THREAD_LIBS_INIT})
add_library(
        scheduler_lib
        src/scheduler.c
        src/scheduler.h
)
target_link_libraries(scheduler_lib workers_lib matrix_lib)

add_executable(codec src/main.c)
target_link_libraries(codec scheduler_lib)
