if(BUILD_SHARED_LIBS)
    set(_build_shared ON)
    set(_build_static OFF)
else()
    set(_build_shared OFF)
    set(_build_static ON)
endif()

if (APPLE)
    message(STATUS "Using apple path for openvdb ${CMAKE_STATIC_LINKER_FLAGS}")
    find_package(zstd REQUIRED)
	# set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} -v -Xlinker -v -v")
	# set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -v -Xlinker -v -v")
	# # set(CMAKE_SHARED_LINKER_FLAGS "-Xlinker -v -v")
	# # set(CMAKE_MODULE_LINKER_FLAGS "-Xlinker -v -v")
	# # set(CMAKE_EXE_LINKER_FLAGS "-Xlinker -v -v")
	# # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -v")
    # message(STATUS "Using apple path for openvdb1 ${CMAKE_STATIC_LINKER_FLAGS}")
    # message(STATUS "Using apple path for openvdb2 ${LDFLAGS}")
	# -DCMAKE_SHARED_LINKER_FLAGS="Wl, -v"
	execute_process(
        COMMAND brew --prefix zstd
        RESULT_VARIABLE BREW_ZSTD
        OUTPUT_VARIABLE BREW_ZSTD_PREFIX
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
	message(STATUS "BREW_ZSTD=${BREW_ZSTD}")
	message(STATUS "BREW_ZSTD_PREFIX=${BREW_ZSTD_PREFIX}")
	message(STATUS "OUTPUT_STRIP_TRAILING_WHITESPACE=${OUTPUT_STRIP_TRAILING_WHITESPACE}")
endif()
if(APPLE AND NOT BUILD_SHARED_LIBS)
	prusaslicer_add_cmake_project(OpenVDB
		URL https://github.com/tamasmeszaros/openvdb/archive/refs/tags/v6.2.1-prusa3d.zip #v6.2.1 patched
		URL_HASH SHA256=caf9f0c91976722883ff9cb32420ef142af22f7e625fc643b91c23d6e4172f62 
		DEPENDS dep_TBB dep_Blosc dep_OpenEXR dep_Boost
		CMAKE_ARGS
			-DCMAKE_POSITION_INDEPENDENT_CODE=ON 
			-DOPENVDB_BUILD_PYTHON_MODULE=OFF
			-DUSE_BLOSC=ON
			-DOPENVDB_CORE_SHARED=${_build_shared} 
			-DOPENVDB_CORE_STATIC=${_build_static}
			-DOPENVDB_ENABLE_RPATH:BOOL=OFF
			-DTBB_STATIC=${_build_static}
			-DOPENVDB_BUILD_VDB_PRINT=OFF
			-DDISABLE_DEPENDENCY_VERSION_CHECKS=ON # Centos6 has old zlib
#			-DCMAKE_STATIC_LINKER_FLAGS="${BREW_ZSTD_PREFIX}/lib/libzstd.a"
	)
else()
	prusaslicer_add_cmake_project(OpenVDB
		URL https://github.com/tamasmeszaros/openvdb/archive/refs/tags/v6.2.1-prusa3d.zip #v6.2.1 patched
		URL_HASH SHA256=caf9f0c91976722883ff9cb32420ef142af22f7e625fc643b91c23d6e4172f62 
		DEPENDS dep_TBB dep_Blosc dep_OpenEXR dep_Boost
		CMAKE_ARGS
			-DCMAKE_POSITION_INDEPENDENT_CODE=ON 
			-DOPENVDB_BUILD_PYTHON_MODULE=OFF
			-DUSE_BLOSC=ON
			-DOPENVDB_CORE_SHARED=${_build_shared} 
			-DOPENVDB_CORE_STATIC=${_build_static}
			-DOPENVDB_ENABLE_RPATH:BOOL=OFF
			-DTBB_STATIC=${_build_static}
			-DOPENVDB_BUILD_VDB_PRINT=ON
			-DDISABLE_DEPENDENCY_VERSION_CHECKS=ON # Centos6 has old zlib
	)
endif()

if (MSVC)
    if (${DEP_DEBUG})
        ExternalProject_Get_Property(dep_OpenVDB BINARY_DIR)
        ExternalProject_Add_Step(dep_OpenVDB build_debug
            DEPENDEES build
            DEPENDERS install
            COMMAND ${CMAKE_COMMAND} ../dep_OpenVDB -DOPENVDB_BUILD_VDB_PRINT=OFF
            COMMAND msbuild /m /P:Configuration=Debug INSTALL.vcxproj
            WORKING_DIRECTORY "${BINARY_DIR}"
        )
    endif ()
endif ()