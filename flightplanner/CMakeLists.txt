# Flightplanner
# Nik Sultana, UPenn, February 2019 -- July 2020

project(Flightplanner)
cmake_minimum_required(VERSION 2.8.8)
set(BOOST_MIN_VERSION "1.66.0")

set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -O0 -g")

find_package(Boost ${BOOST_MIN_VERSION} COMPONENTS context coroutine date_time program_options regex system thread REQUIRED)

add_definitions(-DBOOST_COROUTINES_NO_DEPRECATION_WARNING)

link_directories(${Boost_LIBRARY_DIRS})
include_directories(${Boost_INCLUDE_DIRS})

set(base_DEPS ${CMAKE_DL_LIBS} ${Boost_LIBRARIES})

set(base_SOURCES
  plan.cpp
  table.cpp
  proof.cpp
  network.cpp
  parsing.cpp
  flightplanner.cpp
)

add_executable(flightplanner
        ${base_SOURCES}
)

target_link_libraries(flightplanner ${base_DEPS})

set_target_properties(
        flightplanner PROPERTIES
        FOLDER Bin
        OUTPUT_NAME flightplanner
)
