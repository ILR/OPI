# Minimum version required is 3.10 for built-in CUDA support
cmake_minimum_required (VERSION 3.10)

# disable in source builds (these must be placed before project)
if( ${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "In-source builds are not allowed")
endif()
# State the name of the project/executable and the programming language
project(OPI CXX)

# C++11 is required for OPI
set(CMAKE_CXX_STANDARD 11)

option(ENABLE_FORTRAN_SUPPORT "Enable Fortran (default=ON)" ON)
option(ENABLE_CUDA_SUPPORT "Enable cuda_support" ON)

enable_language(C OPTIONAL)
if(ENABLE_FORTRAN_SUPPORT)
  enable_language(Fortran OPTIONAL)
endif()
if(ENABLE_CUDA_SUPPORT)
  enable_language(CUDA OPTIONAL)
endif()
if(NOT ENABLE_CUDA_SUPPORT)
  add_definitions( -DOPI_DISABLE_CUDA )
endif()

# add module path
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/modules")

# find OpenCL
option(ENABLE_CL_SUPPORT "Enable opencl_support" ON)
if(ENABLE_CL_SUPPORT)
  find_package( OpenCL )
  if( OpenCL_FOUND )
    message("OpenCL Support enabled")
  else()
    message("OpenCL not found - Support disabled")
    set(ENABLE_CL_SUPPORT OFF)
  endif()
endif()
if(NOT ENABLE_CL_SUPPORT)
    add_definitions( -DOPI_DISABLE_OPENCL )
endif()

option(PYTHON_USE_VERSION_3 "Generate python bindings for Python3" ON)

option(ENABLE_PYTHON "Generate Python bindings using SWIG" ON)
  if (ENABLE_PYTHON)
    if (WIN32 AND (CMAKE_BUILD_TYPE STREQUAL "Debug"))
      message(WARNING "Python interface is not supported in debug mode on Windows.")
      set (ENABLE_PYTHON OFF)
  else()
    find_package(SWIG)
    if (${CMAKE_VERSION} VERSION_LESS "3.12")
      if (PYTHON_USE_VERSION_3)
          find_package(PythonLibs 3 REQUIRED)
      else()
          find_package(PythonLibs 2 REQUIRED)
      endif()
      if (${SWIG_FOUND} AND ${PYTHONLIBS_FOUND})
        message("Python support enabled")
      else()
        message("SWIG and/or python libraries missing. Python interface will not be built.")
        set(ENABLE_PYTHON OFF)
      endif()
    else()
      set (ENABLE_PYTHON OFF)
      if (PYTHON_USE_VERSION_3)
        find_package(Python3 COMPONENTS Development)
        if (${SWIG_FOUND} AND ${Python3_FOUND} AND PYTHON_USE_VERSION_3)
          message("Building interface for Python 3")
          set (ENABLE_PYTHON ON)
        endif()
      else()
        find_package(Python2 COMPONENTS Development)
        if (${SWIG_FOUND} AND ${Python2_FOUND})
            message("Building interface for Python 2")
            set (ENABLE_PYTHON ON)
        endif()
      endif()
    endif()
  endif()
endif()

# add drop down menu for build type to gui
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "None" "Debug" "Release" "RelWithDebInfo" "MinSizeRel" )
endif(NOT CMAKE_BUILD_TYPE)

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/fortran_modules)

# look for doxygen
find_package(Doxygen)
if(DOXYGEN_FOUND)
  configure_file(${CMAKE_SOURCE_DIR}/doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/doxyfile @ONLY)
  add_custom_target(doc
    ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/doxyfile
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating API Documentation with doxygen" VERBATIM
  )
else()
  message("Doxygen not found - doc building disabled")
endif()

include_directories( ${CMAKE_BINARY_DIR}/generated)

add_subdirectory(src)

option(ENABLE_EXAMPLES "Build examples" OFF)
if(ENABLE_EXAMPLES)
add_subdirectory(examples)
endif()

install(
  EXPORT OPI-libs
  DESTINATION lib
)
