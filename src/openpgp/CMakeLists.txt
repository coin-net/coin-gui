file(GLOB_RECURSE SOURCES *.cpp)
file(GLOB_RECURSE HEADERS *.h)

# Static CoinGUI builds must never fall back to distro shared crypto libraries.
# Coin's Depends prefix is selected and verified by the top-level GUI CMake.
if(STATIC)
  if(NOT COIN_STATIC_QT_PREFIX)
    message(FATAL_ERROR "Missing Coin Depends prefix for static OpenPGP libraries")
  endif()
  unset(GCRYPT_LIBRARY CACHE)
  unset(GCRYPT_INCLUDE_DIR CACHE)
  unset(GPG_ERROR_LIBRARY CACHE)
  find_library(GCRYPT_LIBRARY NAMES gcrypt
    PATHS
      "${COIN_STATIC_QT_PREFIX}/lib"
      "${COIN_STATIC_QT_PREFIX}/lib/${CMAKE_LIBRARY_ARCHITECTURE}"
    NO_DEFAULT_PATH REQUIRED)
  find_path(GCRYPT_INCLUDE_DIR NAMES gcrypt.h
    PATHS "${COIN_STATIC_QT_PREFIX}/include" NO_DEFAULT_PATH REQUIRED)
  find_library(GPG_ERROR_LIBRARY NAMES gpg-error
    PATHS
      "${COIN_STATIC_QT_PREFIX}/lib"
      "${COIN_STATIC_QT_PREFIX}/lib/${CMAKE_LIBRARY_ARCHITECTURE}"
    NO_DEFAULT_PATH REQUIRED)
  foreach(_coin_pgplib IN ITEMS GCRYPT_LIBRARY GPG_ERROR_LIBRARY)
    if(NOT "${${_coin_pgplib}}" MATCHES "\\.a$")
      message(FATAL_ERROR "Coin OpenPGP dependency is not static: ${${_coin_pgplib}}")
    endif()
  endforeach()
else()
  find_library(GCRYPT_LIBRARY gcrypt REQUIRED)
  find_path(GCRYPT_INCLUDE_DIR gcrypt.h REQUIRED)
  find_library(GPG_ERROR_LIBRARY gpg-error REQUIRED)
endif()

add_library(openpgp
  ${SOURCES}
  ${HEADERS})

target_include_directories(openpgp
  PUBLIC
    ${COIN_CORE_SOURCE_DIR}/contrib/epee/include
    ${GCRYPT_INCLUDE_DIR})

target_link_libraries(openpgp
  PUBLIC
    ${GCRYPT_LIBRARY}
    ${GPG_ERROR_LIBRARY})
