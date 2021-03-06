cmake_minimum_required(VERSION 3.8...3.16 FATAL_ERROR)
project(gpuvmem LANGUAGES CXX CUDA)
find_package(Boost REQUIRED)
option(MEMORY_DEBUG "This sets the GDB debug for CUDA code")
if(Boost_FOUND)
  add_executable(gpuvmem ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cu)
  # Search the compute capability of the first GPU and add CUDA specific FLAGS
  include(${CMAKE_CURRENT_SOURCE_DIR}/cuda_check.cmake)
  file(GLOB SOURCE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cu)
  target_sources(gpuvmem PRIVATE ${SOURCE_FILES})
  target_compile_features(gpuvmem PUBLIC cxx_std_11)

  if(PREFIX)
    set(BINARY_DIR ${PREFIX})
    set_target_properties(gpuvmem
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${BINARY_DIR}
    )
  else()
    set(BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/bin)
    set_target_properties(gpuvmem
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${BINARY_DIR}
    )
  endif()

  message(NOTICE "We are currently using the latest casacore stable version >=v3.2.1")
  message(NOTICE "If one these versions are not installed in your computer, please make sure to install it")
  message(NOTICE "For more information please read the README.md file")
  set(CASACORE_DIR /usr/local/include/casacore)
  target_include_directories(gpuvmem PUBLIC
  ${CASACORE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  ${Boost_INCLUDE_DIRS}
  ${CUDA_TOOLKIT_ROOT_DIR}/samples/common/inc
  )

  get_target_property(TEMP gpuvmem COMPILE_FLAGS)
  if(TEMP STREQUAL "TEMP-NOTFOUND")
    set(TEMP "") # Set to empty string
  else()
    set(TEMP "${TEMP} ") # A space to cleanly separate from existing content
  endif()

  if(MEMORY_DEBUG)
    message(NOTICE "MEMORY DEBUG IS ON")
    set(COMPFLAGS "-g -G -D_FORCE_INLINES -w")
    set(TEMP "${TEMP}${COMPFLAGS}" )
    set_target_properties(gpuvmem PROPERTIES COMPILE_FLAGS ${TEMP} CUDA_SEPARABLE_COMPILATION ON CUDA_STANDARD 11)
    set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xcompiler -fopenmp ${CUDA_NVCC_ARCH_FLAGS}")
  else()
    if(USE_FAST_MATH)
      message(NOTICE "MEMORY DEBUG IS OFF")
      set(COMPFLAGS "-D_FORCE_INLINES -w --use_fast_math -O3")
      set(TEMP "${TEMP}${COMPFLAGS}" )
      set_target_properties(gpuvmem PROPERTIES COMPILE_FLAGS ${TEMP} CUDA_SEPARABLE_COMPILATION ON CUDA_STANDARD 11)
      set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xptxas -O3 -Xcompiler -fopenmp ${CUDA_NVCC_ARCH_FLAGS}")
    else()
      message(NOTICE "MEMORY DEBUG IS OFF")
      set(COMPFLAGS "-D_FORCE_INLINES -w -O3")
      set(TEMP "${TEMP}${COMPFLAGS}" )
      set_target_properties(gpuvmem PROPERTIES COMPILE_FLAGS ${TEMP} CUDA_SEPARABLE_COMPILATION ON CUDA_STANDARD 11)
      set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xptxas -O3 -Xcompiler -fopenmp ${CUDA_NVCC_ARCH_FLAGS}")
    endif()
  endif()

  target_link_libraries(gpuvmem cfitsio m casa_casa casa_tables casa_ms casa_measures cudart cuda cufft stdc++ gomp ${Boost_LIBRARIES})
  # Tests - Tests all the testing datasets
  enable_testing()
  set(TEST_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/tests)
  add_test(antennae bash ${TEST_DIRECTORY}/antennae/test.sh ${BINARY_DIR}/gpuvmem ${TEST_DIRECTORY}/antennae)
  add_test(co65 bash ${TEST_DIRECTORY}/co65/test.sh ${BINARY_DIR}/gpuvmem ${TEST_DIRECTORY}/co65)
  add_test(freq78 bash ${TEST_DIRECTORY}/FREQ78/test.sh ${BINARY_DIR}/gpuvmem ${TEST_DIRECTORY}/FREQ78)
  add_test(m87 bash ${TEST_DIRECTORY}/M87/test.sh ${BINARY_DIR}/gpuvmem ${TEST_DIRECTORY}/M87)
  add_test(selfcalband9 bash ${TEST_DIRECTORY}/selfcalband9/test.sh ${BINARY_DIR}/gpuvmem ${TEST_DIRECTORY}/selfcalband9)
else()
 message(NOTICE Boost is not installed in your system. Please make sure Boost is installed before compiling.)
endif()
