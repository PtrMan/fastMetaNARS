cmake_minimum_required (VERSION 2.8)
project (fastMetaNARS)

SET(SOURCE
  source/mixed/FrequencyCertainty.cpp
  source/mixed/Hash.cpp
  source/mixed/Murmur.cpp
  source/mixed/ReasonerInstance.cpp
  source/mixed/UnifiedTerm.cpp
  source/mixed/Inference.cpp
  source/mixed/PathWalker.cpp
  source/mixed/NumericHelper.cpp

  source/mixed/autogen/Deriver.cpp
)

SET(HEADERS
  source/mixed/Bag.h
  source/mixed/Bloomfilter.h
  source/mixed/ClassicalBelief.h
  source/mixed/ClassicalConcept.h
  source/mixed/ClassicalTask.h
  source/mixed/DualStamp.h
  source/mixed/FrequencyCertainty.h
  source/mixed/Hash.h
  source/mixed/Murmur.h
  source/mixed/ReasonerInstance.h
  source/mixed/Ruletable.h
  source/mixed/StaticBitset.h
  source/mixed/TemplateHelper.h
  source/mixed/TermConcept.h
  source/mixed/TermId.h
  source/mixed/TypedefsAndDefines.h
  source/mixed/UnifiedTerm.h
  source/mixed/UnifiedTermIndex.h
  source/mixed/Inference.h
  source/mixed/InferenceFuture.h
  source/mixed/PathDescriptor.h
  source/mixed/Path.h
  source/mixed/PathWalker.h
  source/mixed/BinaryIndexTree.h
  source/mixed/NumericHelper.h

  source/mixed/autogen/Deriver.h
)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/source/mixed )
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/source/mixed/autogen )


ADD_EXECUTABLE(fastMetaNARS ${SOURCE} ${HEADERS})
set_target_properties(fastMetaNARS PROPERTIES LINKER_LANGUAGE CXX)

set(GTEST_INCLUDE_DIRS "" CACHE FILEPATH "path to gtest include directory")
set(GTEST_LIBRARY_DIRS "" CACHE FILEPATH "path to gtest library directory")

link_directories(${GTEST_LIBRARY_DIRS})
include_directories(${GTEST_INCLUDE_DIRS})
ADD_EXECUTABLE(fastMetaNARSUnittests ${SOURCE}  source/mixed/tests/TestBag.cpp source/mixed/tests/TestinaryIndexTree.cpp   ${HEADERS})
set_target_properties(fastMetaNARSUnittests PROPERTIES LINKER_LANGUAGE CXX)
target_link_libraries(fastMetaNARSUnittests gtest)


