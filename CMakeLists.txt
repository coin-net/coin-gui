cmake_minimum_required(VERSION 3.12)
project(coin-gui)

# Prevent legacy WinSock headers from conflicting with Boost.Asio.
if(MINGW)
  add_compile_options("$<$<COMPILE_LANGUAGE:CXX>:-DWIN32_LEAN_AND_MEAN>")
endif()

include(CMakeDependentOption)

message(STATUS "Initiating compile using CMake ${CMAKE_VERSION}")

set(VERSION_MAJOR "0")
set(VERSION_MINOR "0")
set(VERSION_REVISION "1")
set(VERSION "0.${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION}")

option(STATIC "Link libraries statically, requires static Qt")

option(USE_DEVICE_TREZOR "Trezor support compilation" ON)
option(WITH_SCANNER "Enable webcam QR scanner" OFF)
option(WITH_DESKTOP_ENTRY "Ask to install desktop entry on first startup" ON)
option(WITH_UPDATER "Regularly check for new updates" ON)
option(DEV_MODE "Checkout latest coin master on build" OFF)
cmake_dependent_option(QML_TESTS "Build QML tests" OFF "NOT STATIC;NOT ANDROID;NOT IOS" OFF)
option(SKIP_OPTIONAL_COIN_BINARIES "Don't build optional coin binaries" ON)

if(DEV_MODE)
  # DEV_MODE checks out the coin submodule to master, which requires C++17.
  set(CMAKE_CXX_STANDARD 17)
else()
  set(CMAKE_CXX_STANDARD 14)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_SOURCE_DIR}/cmake")
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)
include(CheckLinkerFlag)

set(BUILD_GUI_DEPS ON)
set(BUILD_64 ON CACHE BOOL "Build 64-bit binaries")

if(NOT MANUAL_SUBMODULES)
  find_package(Git)
  if(GIT_FOUND)
    if(NOT DEV_MODE)
      function (check_submodule relative_path)
        execute_process(COMMAND git rev-parse "HEAD" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${relative_path} OUTPUT_VARIABLE localHead)
        execute_process(COMMAND git rev-parse "HEAD:${relative_path}" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} OUTPUT_VARIABLE checkedHead)
        string(COMPARE EQUAL "${localHead}" "${checkedHead}" upToDate)
        if (upToDate)
          message(STATUS "Submodule '${relative_path}' is up-to-date")
        else()
          message(FATAL_ERROR "Submodule '${relative_path}' is not using the checked head. Please update all submodules with\ngit submodule update --init --force --recursive\nor run cmake with -DMANUAL_SUBMODULES=1,\n or if you want to build from latest master run cmake with -DDEV_MODE=ON,\n or run make devmode")
        endif()
      endfunction ()
      message(STATUS "Checking submodules")
      check_submodule(coin)
    else()
      execute_process(COMMAND ${GIT_EXECUTABLE} fetch WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/coin RESULT_VARIABLE GIT_FETCH_RESULT)
      execute_process(COMMAND ${GIT_EXECUTABLE} checkout -f origin/master WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/coin RESULT_VARIABLE GIT_CHECKOUT_MASTER_RESULT)
      execute_process(COMMAND ${GIT_EXECUTABLE} submodule sync --recursive WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/coin RESULT_VARIABLE GIT_SUBMODULE_SYNC_RESULT)
      execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --force --recursive WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/coin RESULT_VARIABLE GIT_SUBMODULE_UPDATE_RESULT)
      if(NOT GIT_FETCH_RESULT EQUAL "0" OR NOT GIT_CHECKOUT_MASTER_RESULT EQUAL "0" OR NOT GIT_SUBMODULE_SYNC_RESULT EQUAL "0" OR NOT GIT_SUBMODULE_UPDATE_RESULT EQUAL "0")
        message(FATAL_ERROR "Updating git submodule to master (-DDEV_MODE=ON) failed")
      endif()
    endif()
  endif()
endif()

# Coin: the GUI must use the modified Coin consensus/wallet source,
# not the upstream Coin submodule. No submodule replacement is needed.
set(COIN_CORE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/coin" CACHE PATH
    "Coin core source containing Coin consensus and wallet code")
if(NOT EXISTS "${COIN_CORE_SOURCE_DIR}/CMakeLists.txt")
    message(FATAL_ERROR "Coin core not found: ${COIN_CORE_SOURCE_DIR}")
endif()
if(DEV_MODE)
    message(FATAL_ERROR "DEV_MODE must be OFF for Coin (never auto-checkout upstream Coin)")
endif()
add_subdirectory("${COIN_CORE_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/coin")

if(SKIP_OPTIONAL_COIN_BINARIES)
  foreach(_optional_coin_target
      simplewallet
      gen_multisig
      gen_ssl_cert
      wallet_rpc_server
      blockchain_import
      blockchain_export
      blockchain_blackball
      blockchain_usage
      blockchain_ancestry
      blockchain_depth
      blockchain_stats
      blockchain_prune_known_spent_data
      blockchain_prune)
    if(TARGET ${_optional_coin_target})
      set_target_properties(${_optional_coin_target} PROPERTIES EXCLUDE_FROM_ALL TRUE)
    endif()
  endforeach()
endif()

add_subdirectory(external)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

get_directory_property(ARCH_WIDTH DIRECTORY "${COIN_CORE_SOURCE_DIR}" DEFINITION ARCH_WIDTH)
get_directory_property(Boost_VERSION_STRING DIRECTORY "${COIN_CORE_SOURCE_DIR}" DEFINITION Boost_VERSION_STRING)

if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_definitions(-DQT_NO_DEBUG)
endif()

if(STATIC)
  message(STATUS "Initiating static build")
  set(CMAKE_FIND_LIBRARY_SUFFIXES ".a" ${CMAKE_FIND_LIBRARY_SUFFIXES})
  add_definitions(-DCOIN_GUI_STATIC)
endif()

include(CMakePackageConfigHelpers)

include_directories(${EASYLOGGING_INCLUDE})
link_directories(${EASYLOGGING_LIBRARY_DIRS})

include(VersionGui)

message(STATUS "${CMAKE_MODULE_PATH}")

if(WITH_SCANNER)
    add_definitions(-DWITH_SCANNER)
endif()

if(WITH_DESKTOP_ENTRY)
    add_definitions(-DWITH_DESKTOP_ENTRY)
endif()

if(WITH_UPDATER)
    add_definitions(-DWITH_UPDATER)
endif()

# Sodium
find_library(SODIUM_LIBRARY sodium)
message(STATUS "libsodium: libraries at ${SODIUM_LIBRARY}")

if(UNIX AND NOT APPLE AND NOT ANDROID)
    set(CMAKE_SKIP_RPATH ON)
    if(STATIC)
        find_library(XCB_LIBRARY xcb)
        message(STATUS "Found xcb library: ${XCB_LIBRARY}")
    endif()
endif()

set(QT5_LIBRARIES
  Qt5Core
  Qt5Quick
  Qt5Gui
  Qt5Qml
  Qt5Svg
  Qt5Xml
)

if(QML_TESTS)
  list(APPEND QT5_LIBRARIES Qt5QuickTest Qt5Test)
endif()

if(WITH_SCANNER)
  list(APPEND QT5_LIBRARIES Qt5Multimedia)
endif()

if(APPLE)
  list(APPEND QT5_LIBRARIES Qt5MacExtras)
endif()

if(UNIX)
  if(NOT CMAKE_PREFIX_PATH AND DEFINED ENV{CMAKE_PREFIX_PATH})
    message(STATUS "Using CMAKE_PREFIX_PATH environment variable: '$ENV{CMAKE_PREFIX_PATH}'")
    set(CMAKE_PREFIX_PATH $ENV{CMAKE_PREFIX_PATH})
  endif()
  if(APPLE AND NOT CMAKE_PREFIX_PATH)
    execute_process(COMMAND brew --prefix qt5 OUTPUT_VARIABLE QT5_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
    list(APPEND CMAKE_PREFIX_PATH ${QT5_DIR})
  endif()
endif()

set(QT_MIN_VERSION "5.12")

find_package(PkgConfig REQUIRED)

# TODO: drop this once we switch to Qt 5.14+
pkg_check_modules(Qt5QmlModels_PKG_CONFIG QUIET Qt5QmlModels)
if(Qt5QmlModels_PKG_CONFIG_FOUND)
  list(APPEND QT5_LIBRARIES Qt5QmlModels)
endif()

foreach(QT5_MODULE ${QT5_LIBRARIES})
  find_package(${QT5_MODULE} ${QT_MIN_VERSION} REQUIRED)
  include_directories(${${QT5_MODULE}_INCLUDE_DIRS})
endforeach()

# Preserve the module names: QT5_LIBRARIES below is the actual link list.
set(COIN_QT5_MODULE_NAMES ${QT5_LIBRARIES})

if(STATIC AND ((UNIX AND NOT APPLE) OR MINGW))
  # Static Qt's CMake imported targets already carry their transitive native
  # link dependencies. Do not ALSO inject pkg-config --static's flattened
  # -lQt5* / -lcrypto / -lz flags into the same executable link line.
  set(QT5_LIBRARIES)
  foreach(_coin_qt_module IN LISTS COIN_QT5_MODULE_NAMES)
    string(REGEX REPLACE "^Qt5" "Qt5::" _coin_qt_target "${_coin_qt_module}")
    if(NOT TARGET ${_coin_qt_target})
      message(FATAL_ERROR "Missing Qt static CMake target: ${_coin_qt_target}")
    endif()
    list(APPEND QT5_LIBRARIES ${_coin_qt_target})
  endforeach()
else()
if(NOT (CMAKE_CROSSCOMPILING AND ANDROID))
  pkg_check_modules(QT5_PKG_CONFIG REQUIRED ${QT5_LIBRARIES})
else()
  set(QT5_LIBRARIES_ABI)
  foreach(QT5_MODULE ${QT5_LIBRARIES})
    list(APPEND QT5_LIBRARIES_ABI "${QT5_MODULE}_${CMAKE_ANDROID_ARCH_ABI}")
  endforeach()
  pkg_check_modules(QT5_PKG_CONFIG REQUIRED ${QT5_LIBRARIES_ABI})
endif()

get_target_property(QMAKE_IMPORTED_LOCATION Qt5::qmake IMPORTED_LOCATION)
get_filename_component(QT_INSTALL_PREFIX "${QMAKE_IMPORTED_LOCATION}/../.." ABSOLUTE)

if(APPLE AND NOT STATIC)
  set(CMAKE_BUILD_RPATH "${QT_INSTALL_PREFIX}/lib")
endif()

if(QT5_PKG_CONFIG_FOUND)
  set(QT5_PKG_CONFIG "QT5_PKG_CONFIG")
  if(STATIC)
    set(QT5_PKG_CONFIG "${QT5_PKG_CONFIG}_STATIC")
  endif()

  if(UNIX AND CMAKE_PREFIX_PATH)
    if(APPLE)
      list(JOIN ${QT5_PKG_CONFIG}_LDFLAGS_OTHER " " ${QT5_PKG_CONFIG}_LDFLAGS_OTHER)
    endif()
    # temporal workaround for https://bugreports.qt.io/browse/QTBUG-80922
    STRING(REPLACE "${QT5_PKG_CONFIG_Qt5Core_PREFIX}" "${QT_INSTALL_PREFIX}" ${QT5_PKG_CONFIG}_LDFLAGS_OTHER "${${QT5_PKG_CONFIG}_LDFLAGS_OTHER}")
    STRING(REPLACE "${QT5_PKG_CONFIG_Qt5Core_PREFIX}" "${QT_INSTALL_PREFIX}" ${QT5_PKG_CONFIG}_LIBRARIES "${${QT5_PKG_CONFIG}_LIBRARIES}")
    STRING(REPLACE "${QT5_PKG_CONFIG_Qt5Core_PREFIX}" "${QT_INSTALL_PREFIX}" ${QT5_PKG_CONFIG}_INCLUDE_DIRS "${${QT5_PKG_CONFIG}_INCLUDE_DIRS}")
    STRING(REPLACE "${QT5_PKG_CONFIG_Qt5Core_PREFIX}" "${QT_INSTALL_PREFIX}" ${QT5_PKG_CONFIG}_LIBRARY_DIRS "${${QT5_PKG_CONFIG}_LIBRARY_DIRS}")
  endif()

  set(QT5_LIBRARIES ${${QT5_PKG_CONFIG}_LIBRARIES} ${${QT5_PKG_CONFIG}_LDFLAGS_OTHER})
  include_directories(${${QT5_PKG_CONFIG}_INCLUDE_DIRS})
  link_directories(${${QT5_PKG_CONFIG}_LIBRARY_DIRS})
endif()
endif() # static Linux/MinGW: imported Qt5:: targets, rather than pkg-config Qt flags

list(APPEND QT5_LIBRARIES
  ${Qt5Gui_PLUGINS}
  ${Qt5Svg_PLUGINS}
  ${Qt5Qml_PLUGINS}
  ${Qt5Network_PLUGINS}
)

if(STATIC)
  # Derive the Qt root from the Qt5Core CMake package that CMake selected,
  # not from a PkgConfig module prefix or a host qmake path.
  # This avoids mixing static GUI libraries from distinct Qt installations.
  get_filename_component(COIN_STATIC_QT_PREFIX "${Qt5Core_DIR}/../../.." ABSOLUTE)
  if(NOT EXISTS "${COIN_STATIC_QT_PREFIX}/lib/libQt5Core.a")
    message(FATAL_ERROR "Expected static Depends Qt at ${COIN_STATIC_QT_PREFIX}")
  endif()
  message(STATUS "Coin static Qt installation: ${COIN_STATIC_QT_PREFIX}")
  # Qt 5 emits some native dependencies as bare -lfontconfig / -lfreetype
  # (from .prl files). The Depends prefix MUST precede distro -L paths.
  link_directories(BEFORE "${COIN_STATIC_QT_PREFIX}/lib")
  if(UNIX AND NOT APPLE)
    foreach(_coin_fontlib IN ITEMS freetype fontconfig)
      if(NOT EXISTS "${COIN_STATIC_QT_PREFIX}/lib/lib${_coin_fontlib}.a")
        message(FATAL_ERROR "Missing Depends release archive: lib${_coin_fontlib}.a")
      endif()
    endforeach()
    # Validate that pkg-config reports the isolated Coin-release copies.
    execute_process(COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=libdir fontconfig
      OUTPUT_VARIABLE _coin_fc_libdir OUTPUT_STRIP_TRAILING_WHITESPACE
      RESULT_VARIABLE _coin_fc_result)
    if(NOT _coin_fc_result EQUAL 0 OR
       NOT _coin_fc_libdir STREQUAL "${COIN_STATIC_QT_PREFIX}/lib")
      message(FATAL_ERROR "fontconfig pkg-config escaped Depends: '${_coin_fc_libdir}'")
    endif()
  endif()
  set(QT5_EXTRA_PATHS "${COIN_STATIC_QT_PREFIX}/lib")
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/Qt/labs/folderlistmodel)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/Qt/labs/settings)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/Qt/labs/platform)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtGraphicalEffects)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtGraphicalEffects/private)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtMultimedia)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQml)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQml/Models.2)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQml/WorkerScript.2)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQuick.2)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQuick/Controls)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQuick/Controls.2)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQuick/Dialogs)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQuick/Dialogs/Private)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQuick/Layouts)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQuick/PrivateWidgets)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQuick/Templates.2)
  list(APPEND QT5_EXTRA_PATHS ${COIN_STATIC_QT_PREFIX}/qml/QtQuick/Window.2)

  set(QT5_EXTRA_LIBRARIES_LIST
    qtquicktemplates2plugin
    Qt5QuickTemplates2
    qtquickcontrols2plugin
    Qt5QuickControls2
    dialogplugin
    dialogsprivateplugin
    qmlfolderlistmodelplugin
    qmlsettingsplugin
    qtlabsplatformplugin
    qquicklayoutsplugin
    modelsplugin
  )

  if(WITH_SCANNER)
    list(APPEND QT5_EXTRA_LIBRARIES_LIST
      declarative_multimedia
      Qt5MultimediaQuick
    )
  endif()

  list(APPEND QT5_EXTRA_LIBRARIES_LIST
    qtgraphicaleffectsplugin
    qtgraphicaleffectsprivate
    qtquick2plugin
    workerscriptplugin
    Qt5QmlWorkerScript
    qtquickcontrolsplugin
    widgetsplugin
    windowplugin
  )

  if(NOT ${Qt5Core_VERSION} VERSION_LESS 5.14)
     list(APPEND QT5_EXTRA_LIBRARIES_LIST qmlplugin)
  endif()

  set(QT5_EXTRA_LIBRARIES)
  foreach(LIBRARY IN LISTS QT5_EXTRA_LIBRARIES_LIST)
    find_library(${LIBRARY}_LIBRARY NAMES ${LIBRARY}
      PATHS ${QT5_EXTRA_PATHS} NO_DEFAULT_PATH)
    if(NOT ${LIBRARY}_LIBRARY)
      message(FATAL_ERROR
        "Missing static Qt plugin/library '${LIBRARY}' in Depends Qt at "
        "${COIN_STATIC_QT_PREFIX}. Search for lib${LIBRARY}.a under "
        "${COIN_STATIC_QT_PREFIX}; if absent, Qt Depends did not build/install "
        "this required GUI component. No system Qt fallback is allowed.")
    endif()
    if(NOT "${${LIBRARY}_LIBRARY}" MATCHES "\\.a$")
      message(FATAL_ERROR "Qt dependency is not a static archive: ${${LIBRARY}_LIBRARY}")
    endif()
    list(APPEND QT5_EXTRA_LIBRARIES ${${LIBRARY}_LIBRARY})
  endforeach()

  if(MINGW)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
      list(APPEND QT5_EXTRA_LIBRARIES D3D11 Dwrite D2d1)
    endif()
  endif()

  set(QT5_LIBRARIES
    ${QT5_EXTRA_LIBRARIES}
    ${QT5_LIBRARIES}
  )

  set(QT5_INTEGRATION_LIBRARIES_LIST
    Qt5EventDispatcherSupport
    Qt5PacketProtocol
    Qt5ThemeSupport
    Qt5FontDatabaseSupport
  )

  if(UNIX AND NOT APPLE)
    list(APPEND QT5_INTEGRATION_LIBRARIES_LIST
      Qt5XcbQpa
      Qt5ServiceSupport
      Qt5GlxSupport
    )
  elseif(MINGW)
    list(APPEND QT5_INTEGRATION_LIBRARIES_LIST qtfreetype)
  endif()

  foreach(LIBRARY IN LISTS QT5_INTEGRATION_LIBRARIES_LIST)
    find_library(${LIBRARY}_LIBRARY NAMES ${LIBRARY}
      PATHS ${QT5_EXTRA_PATHS} NO_DEFAULT_PATH)
    if(NOT ${LIBRARY}_LIBRARY)
      message(FATAL_ERROR
        "Missing Qt integration archive lib${LIBRARY}.a under ${COIN_STATIC_QT_PREFIX}")
    endif()
    list(APPEND QT5_LIBRARIES ${${LIBRARY}_LIBRARY})
  endforeach()

  if(UNIX AND NOT APPLE)
    pkg_check_modules(X11XCB_XCBGLX REQUIRED x11-xcb xcb-glx)
    list(APPEND QT5_LIBRARIES ${X11XCB_XCBGLX_LIBRARIES})
    pkg_check_modules(FONTCONFIG REQUIRED fontconfig)
    list(APPEND QT5_LIBRARIES ${FONTCONFIG_STATIC_LIBRARIES})

    # Qt's imported TIFF and XCB plugins reference distro static codecs/font
    # libraries. The installed Qt CMake exports do not always record their
    # private pkg-config requirements. Attach the native (NOT Qt!) closure
    # to the plugin that actually needs it, so GNU ld sees it after its
    # dependent archive rather than adding global flags in arbitrary order.
    foreach(_coin_qt_native_spec IN ITEMS "Qt5::QTiffPlugin|libtiff-4|tiff,z"
                                         "Qt5::QXcbIntegrationPlugin|freetype2|freetype,z")
      string(REPLACE "|" ";" _coin_qt_parts "${_coin_qt_native_spec}")
      list(GET _coin_qt_parts 0 _coin_qt_plugin)
      list(GET _coin_qt_parts 1 _coin_qt_pc)
      list(GET _coin_qt_parts 2 _coin_qt_excluded)
      string(REPLACE "," ";" _coin_qt_excluded "${_coin_qt_excluded}")
      if(TARGET ${_coin_qt_plugin})
        string(REGEX REPLACE "[^A-Za-z0-9]" "_" _coin_qt_pc_key "${_coin_qt_pc}")
        set(_coin_qt_pc_var "COIN_QT_NATIVE_${_coin_qt_pc_key}")
        pkg_check_modules(${_coin_qt_pc_var} QUIET ${_coin_qt_pc})
        if(NOT ${_coin_qt_pc_var}_FOUND)
          message(STATUS "Optional native Qt link metadata not available: ${_coin_qt_pc}")
          continue()
        endif()
        set(_coin_qt_native_deps)
        foreach(_coin_qt_native_lib IN LISTS ${_coin_qt_pc_var}_STATIC_LIBRARIES)
          # TIFF/FreeType themselves are already in the plugin's link graph.
          # zlib is attached once to Qt5::Gui below, after Qt's native libs.
          if(_coin_qt_native_lib IN_LIST _coin_qt_excluded)
            continue()
          endif()
          # Let CMake resolve system native dependencies; prefer archives
          # in STATIC builds, as configured by CMAKE_FIND_LIBRARY_SUFFIXES.
          string(REGEX REPLACE "[^A-Za-z0-9]" "_" _coin_qt_libkey "${_coin_qt_native_lib}")
          set(_coin_qt_libvar "COIN_NATIVE_${_coin_qt_libkey}")
          if(_coin_qt_native_lib MATCHES "^(m|pthread|rt|dl|c)$")
            # Avoid pulling glibc's standalone libm.a/libpthread.a into a
            # dynamically linked Linux executable (PIE + system GL/X11).
            list(APPEND _coin_qt_native_deps "${_coin_qt_native_lib}")
          else()
            find_library(${_coin_qt_libvar} NAMES ${_coin_qt_native_lib})
            if(${_coin_qt_libvar})
              list(APPEND _coin_qt_native_deps "${${_coin_qt_libvar}}")
            else()
              list(APPEND _coin_qt_native_deps "${_coin_qt_native_lib}")
            endif()
          endif()
        endforeach()
        set_property(TARGET ${_coin_qt_plugin} APPEND PROPERTY
                     INTERFACE_LINK_LIBRARIES "${_coin_qt_native_deps}")
      endif()
    endforeach()

    # The Qt image, XCB, and font plugins bring system static archives onto
    # the executable's link line via Qt5::Gui's CMake interface. Their private
    # dependencies must FOLLOW those archives; adding them to the executable
    # directly puts them too early. Never WHOLE_ARCHIVE zlib: CMake may repeat
    # a static imported target during traversal, causing duplicate symbols.
    set(ZLIB_USE_STATIC_LIBS ON)
    find_package(ZLIB REQUIRED)
    # FreeType's sfnt and bzip2 modules use these archives. The old Qt link
    # had both libraries in the wrong position for FreeType static linkage.
    find_library(COIN_PNG_LIBRARY NAMES png16 REQUIRED)
    foreach(_coin_static_native IN ITEMS ZLIB_LIBRARY COIN_PNG_LIBRARY)
      if(NOT "${${_coin_static_native}}" MATCHES "\\.a$")
        message(FATAL_ERROR "Coin GUI requires a static native dependency: ${_coin_static_native}=${${_coin_static_native}}")
      endif()
    endforeach()
    if(NOT TARGET Qt5::Gui)
      message(FATAL_ERROR "Missing Qt5::Gui imported CMake target")
    endif()
    # These are the private requirements of the already-linked Qt plugins:
    #   TIFF, FreeType -> zlib; WebP -> SharpYUV; XCB image -> xcb-util.
    # APPEND preserves the existing order of Qt's private native dependencies.
    # Keep release font archives in the Qt native interface closure.
    # This is explicit; static Qt alone does not make fontconfig static.
    set_property(TARGET Qt5::Gui APPEND PROPERTY INTERFACE_LINK_LIBRARIES
      "${COIN_STATIC_QT_PREFIX}/lib/libfontconfig.a;${COIN_STATIC_QT_PREFIX}/lib/libfreetype.a;${COIN_PNG_LIBRARY};${ZLIB_LIBRARY}")
  endif()
endif()

if(ANDROID)
  set(QT5_EXTRA_LIBRARIES_LIST
    GLESv2
    log
    z
    jnigraphics
    android
    EGL
    Qt5VirtualKeyboard_${CMAKE_ANDROID_ARCH_ABI}
    c++_shared
  )
  foreach(LIBRARY ${QT5_EXTRA_LIBRARIES_LIST})
    find_library(${LIBRARY}_LIBRARY ${LIBRARY} PATHS "${ANDROID_TOOLCHAIN_ROOT}/sysroot/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}/${ANDROID_PLATFORM_LEVEL}" REQUIRED)
    list(APPEND QT5_LIBRARIES ${${LIBRARY}_LIBRARY})
  endforeach()
endif()

if(MINGW)
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Wa,-mbig-obj")
  set(EXTRA_LIBRARIES mswsock;ws2_32;iphlpapi;crypt32;bcrypt)
  if(DEPENDS)
    set(ICU_LIBRARIES icuio icui18n icuuc icudata icutu iconv)
  else()
    set(ICU_LIBRARIES icuio icuin icuuc icudt icutu iconv)
  endif()
elseif(APPLE)
  set(EXTRA_LIBRARIES "-framework AppKit")
elseif(OPENBSD OR ANDROID)
  set(EXTRA_LIBRARIES "")
elseif(FREEBSD)
  set(EXTRA_LIBRARIES execinfo)
elseif(DRAGONFLY)
  find_library(COMPAT compat)
  set(EXTRA_LIBRARIES execinfo ${COMPAT})
elseif(CMAKE_SYSTEM_NAME MATCHES "(SunOS|Solaris)")
  set(EXTRA_LIBRARIES socket nsl resolv)
elseif(NOT MSVC AND NOT DEPENDS)
  find_library(RT rt)
  set(EXTRA_LIBRARIES ${RT})
endif()

list(APPEND EXTRA_LIBRARIES ${CMAKE_DL_LIBS})

if(APPLE)
  cmake_policy(SET CMP0042 NEW)
endif()

if (APPLE AND NOT IOS)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=default")
endif()

if(APPLE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=default -DGTEST_HAS_TR1_TUPLE=0")
endif()

# warnings
add_c_flag_if_supported(-Wformat C_SECURITY_FLAGS)
add_cxx_flag_if_supported(-Wformat CXX_SECURITY_FLAGS)
add_c_flag_if_supported(-Wformat-security C_SECURITY_FLAGS)
add_cxx_flag_if_supported(-Wformat-security CXX_SECURITY_FLAGS)

# -fstack-protector
if (NOT OPENBSD AND NOT (WIN32 AND (CMAKE_C_COMPILER_ID STREQUAL "GNU" AND CMAKE_C_COMPILER_VERSION VERSION_LESS 9.1)))
  add_c_flag_if_supported(-fstack-protector C_SECURITY_FLAGS)
  add_cxx_flag_if_supported(-fstack-protector CXX_SECURITY_FLAGS)
  add_c_flag_if_supported(-fstack-protector-strong C_SECURITY_FLAGS)
  add_cxx_flag_if_supported(-fstack-protector-strong CXX_SECURITY_FLAGS)
endif()

# New in GCC 8.2
if (NOT OPENBSD AND NOT (WIN32 AND (CMAKE_C_COMPILER_ID STREQUAL "GNU" AND CMAKE_C_COMPILER_VERSION VERSION_LESS 9.1)))
  add_c_flag_if_supported(-fcf-protection=full C_SECURITY_FLAGS)
  add_cxx_flag_if_supported(-fcf-protection=full CXX_SECURITY_FLAGS)
endif()
if (NOT WIN32 AND NOT OPENBSD AND NOT "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
  add_c_flag_if_supported(-fstack-clash-protection C_SECURITY_FLAGS)
  add_cxx_flag_if_supported(-fstack-clash-protection CXX_SECURITY_FLAGS)
endif()

# Removed in GCC 9.1 (or before ?), but still accepted, so spams the output
if (NOT (CMAKE_C_COMPILER_ID STREQUAL "GNU" AND NOT CMAKE_C_COMPILER_VERSION VERSION_LESS 9.1))
  add_c_flag_if_supported(-mmitigate-rop C_SECURITY_FLAGS)
  add_cxx_flag_if_supported(-mmitigate-rop CXX_SECURITY_FLAGS)
endif()

# linker
if (APPLE)
  add_linker_flag_if_supported(-Wl,-bind_at_load LD_SECURITY_FLAGS)
  add_linker_flag_if_supported(-Wl,-dead_strip LD_SECURITY_FLAGS)
  add_linker_flag_if_supported(-Wl,-dead_strip_dylibs LD_SECURITY_FLAGS)
endif()
if (NOT APPLE AND NOT (WIN32 AND CMAKE_C_COMPILER_ID STREQUAL "GNU"))
  # Windows binaries die on startup with PIE when compiled with GCC
  add_linker_flag_if_supported(-pie LD_SECURITY_FLAGS)
endif()
add_linker_flag_if_supported(-Wl,-z,relro LD_SECURITY_FLAGS)
add_linker_flag_if_supported(-Wl,-z,now LD_SECURITY_FLAGS)
add_linker_flag_if_supported(-Wl,-z,noexecstack noexecstack_SUPPORTED)
if (noexecstack_SUPPORTED)
  set(LD_SECURITY_FLAGS "${LD_SECURITY_FLAGS} -Wl,-z,noexecstack")
endif()
add_linker_flag_if_supported(-Wl,-z,noexecheap noexecheap_SUPPORTED)
if (noexecheap_SUPPORTED)
  set(LD_SECURITY_FLAGS "${LD_SECURITY_FLAGS} -Wl,-z,noexecheap")
endif()

# some windows linker bits
if (WIN32)
  add_linker_flag_if_supported(-Wl,--dynamicbase LD_SECURITY_FLAGS)
  add_linker_flag_if_supported(-Wl,--nxcompat LD_SECURITY_FLAGS)
  add_linker_flag_if_supported(-Wl,--high-entropy-va LD_SECURITY_FLAGS)
endif()

if(STATIC)
  add_linker_flag_if_supported(-static-libgcc STATIC_FLAGS)
  add_linker_flag_if_supported(-static-libstdc++ STATIC_FLAGS)
  if(MINGW)
    add_linker_flag_if_supported(-static STATIC_FLAGS)
  endif()
endif()

# With GCC 6.1.1 the compiled binary malfunctions due to aliasing. Until that
# is fixed in the code (Issue #847), force compiler to be conservative.
add_c_flag_if_supported(-fno-strict-aliasing C_SECURITY_FLAGS)
add_cxx_flag_if_supported(-fno-strict-aliasing CXX_SECURITY_FLAGS)

add_c_flag_if_supported(-fPIC C_SECURITY_FLAGS)
add_cxx_flag_if_supported(-fPIC CXX_SECURITY_FLAGS)

message(STATUS "Using C security hardening flags: ${C_SECURITY_FLAGS}")
message(STATUS "Using C++ security hardening flags: ${CXX_SECURITY_FLAGS}")
message(STATUS "Using linker security hardening flags: ${LD_SECURITY_FLAGS}")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11 ${C_SECURITY_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_SECURITY_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LD_SECURITY_FLAGS} ${STATIC_FLAGS}")

add_subdirectory(translations)
add_subdirectory(src)
