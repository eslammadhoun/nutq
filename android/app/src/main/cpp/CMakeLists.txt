cmake_minimum_required(VERSION 3.22.1)
project(nutq_moonshine CXX)

# A thin JNI layer over Moonshine's C API. libmoonshine.so itself ships in the
# ai.moonshine:moonshine-voice AAR; this library finds it at run time with
# dlopen, so the build does not need to reach into the AAR.
add_library(nutq_moonshine SHARED nutq_moonshine.cpp)

target_include_directories(nutq_moonshine PRIVATE include)
target_compile_features(nutq_moonshine PRIVATE cxx_std_17)
target_compile_options(nutq_moonshine PRIVATE -Wall -Wextra -Werror -fvisibility=hidden)
target_link_libraries(nutq_moonshine PRIVATE log dl)
