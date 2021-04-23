set(OUTPUT_HEADER_FILE ${OUTPUT_PATH}/opi_c_bindings.h)
set(OUTPUT_SOURCE_FILE ${OUTPUT_PATH}/opi_c_bindings.cpp)
include(ParseArguments)

file(WRITE ${OUTPUT_SOURCE_FILE} "/******************************************************************\n")
file(APPEND ${OUTPUT_SOURCE_FILE} " * FILE GENERATED BY BUILDSYS FROM ${PROCESS_FILE}\n")
file(APPEND ${OUTPUT_SOURCE_FILE} " * DO NOT EDIT MANUALLY\n")
file(APPEND ${OUTPUT_SOURCE_FILE} " *****************************************************************/\n")
file(APPEND ${OUTPUT_SOURCE_FILE} "#include \"opi_c_bindings.h\"\n")
file(APPEND ${OUTPUT_SOURCE_FILE} "#include \"opi_cpp.h\"\n")
file(APPEND ${OUTPUT_SOURCE_FILE} "extern \"C\" {\n")
file(WRITE ${OUTPUT_HEADER_FILE}  "/******************************************************************\n")
file(APPEND ${OUTPUT_HEADER_FILE} " * FILE GENERATED BY BUILDSYS FROM ${PROCESS_FILE}\n")
file(APPEND ${OUTPUT_HEADER_FILE} " * DO NOT EDIT MANUALLY\n")
file(APPEND ${OUTPUT_HEADER_FILE} " *****************************************************************/\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#ifndef OPI_C_BINDINGS_H\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#define OPI_C_BINDINGS_H\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#if WIN32\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#ifdef OPI_COMPILING_DYNAMIC_LIBRARY\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#define OPI_API_EXPORT __declspec( dllexport )\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#else\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#define OPI_API_EXPORT __declspec( dllimport )\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#endif\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#else\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#define OPI_API_EXPORT\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#endif\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#ifdef __cplusplus\n")
file(APPEND ${OUTPUT_HEADER_FILE} "extern \"C\" {\n")
file(APPEND ${OUTPUT_HEADER_FILE} "#endif\n")
file(APPEND ${OUTPUT_HEADER_FILE} "typedef void* OPI_Host;\n")
file(APPEND ${OUTPUT_HEADER_FILE} "typedef void (*OPI_ErrorCallback)(OPI_Host host, int errorcode, void* privatedata);\n")

macro(BEGIN_STRUCTURE TYPENAME)
file(APPEND ${OUTPUT_HEADER_FILE} "typedef struct OPI_${TYPENAME}_t\n")
file(APPEND ${OUTPUT_HEADER_FILE} "{\n")
endmacro()
macro(STRUCTURE_VARIABLE TYPE NAME)
if(${TYPE} STREQUAL "JulianDay")
  file(APPEND ${OUTPUT_HEADER_FILE} "\tOPI_${TYPE} ${NAME};\n")
else()
  file(APPEND ${OUTPUT_HEADER_FILE} "\t${TYPE} ${NAME};\n")
endif()
endmacro()
macro(END_STRUCTURE TYPENAME)
file(APPEND ${OUTPUT_HEADER_FILE} "} OPI_${TYPENAME};\n")
endmacro()

macro(COMMENT COMMENT_TO_WRITE)
file(APPEND ${OUTPUT_HEADER_FILE} "/// ${COMMENT_TO_WRITE}\n")
endmacro()

macro(BEGIN_ENUM TYPENAME)
file(APPEND ${OUTPUT_HEADER_FILE} "enum OPI_ENUM_${TYPENAME}\n{\n")
endmacro()
macro(BEGIN_ENUM_AS_INT TYPENAME)
set(ENUM_TYPE_AS_INT_${TYPENAME} 1)
file(APPEND ${OUTPUT_HEADER_FILE} "typedef int OPI_${TYPENAME};\n")
file(APPEND ${OUTPUT_HEADER_FILE} "enum OPI_ENUM_${TYPENAME}\n{\n")
endmacro()
macro(ENUM_VALUE NAME VALUE)
file(APPEND ${OUTPUT_HEADER_FILE} "\tOPI_${NAME} = ${VALUE},\n")
endmacro()
macro(END_ENUM TYPENAME)
  file(APPEND ${OUTPUT_HEADER_FILE} "};\n")
  if(NOT ENUM_TYPE_AS_INT_${TYPENAME})
    file(APPEND ${OUTPUT_HEADER_FILE} "typedef enum OPI_ENUM_${TYPENAME} OPI_${TYPENAME};\n")
  endif()
endmacro()

macro(PARSE_TYPE TYPE)
  set(REFCAST)
  unset(TYPE_IS_ENUM)
  unset(TYPE_IS_STRING)
  if(${${TYPE}} STREQUAL "void*")
  elseif(${${TYPE}} STREQUAL "int")
  elseif(${${TYPE}} STREQUAL "int*")
  elseif(${${TYPE}} STREQUAL "float")
  elseif(${${TYPE}} STREQUAL "float*")
  elseif(${${TYPE}} STREQUAL "double")
  elseif(${${TYPE}} STREQUAL "double*")
  elseif(${${TYPE}} STREQUAL "long")
  elseif(${${TYPE}} STREQUAL "long*")
  elseif(${${TYPE}} STREQUAL "const char*")
    set(TYPE_IS_STRING 1)
  elseif(${${TYPE}} STREQUAL "std::string")
    set(TYPE_IS_STRING 1)
  elseif(${${TYPE}} STREQUAL "PropagationMode")
    set(TYPE_IS_ENUM 1)
    set(${TYPE} "OPI_PropagationMode")
  elseif(${${TYPE}} STREQUAL "JulianDay")
    set(${TYPE} "OPI_JulianDay")
  else()
    if(${${TYPE}} MATCHES "(.*)&")
      #string(REGEX MATCH "(.*)&" RESULT ${${TYPE}})
      set(REFCAST "${CMAKE_MATCH_1}")
      set(${TYPE} "OPI_${CMAKE_MATCH_1}")
    else()
    set(${TYPE} "OPI_${${TYPE}}")
    endif()
  endif()
endmacro()

macro(PARSE_FUNCTION_ARGS ARGS)
    list(LENGTH ${ARGS} ARG_LEN)
    set(MAKE_STRINGWRAP)
    math(EXPR ARG_LEN "${ARG_LEN} - 1")
    if(${ARG_LEN} GREATER 0)
      foreach(INDEX RANGE 0 ${ARG_LEN} 2)
        list(GET ${ARGS} ${INDEX} TYPE)
        math(EXPR INDEX_2 "${INDEX} + 1")
        list(GET ${ARGS} ${INDEX_2} NAME)
        if(${TYPE} STREQUAL "const char*")
          set(MAKE_STRINGWRAP 1)
          list(APPEND ARG_FUNCTION_BODY "const char* ${NAME}")
          list(APPEND ARG_FUNCTION_BODY_WRAP "const char* ${NAME}, int ${NAME}_len")
          list(APPEND ARG_FUNCTION_CALL "${NAME}")
          list(APPEND ARG_FUNCTION_CALL_WRAP "std::string(${NAME}, ${NAME}_len).c_str()")
        else()
          PARSE_TYPE(TYPE)
          if(${TYPE} STREQUAL "OPI_IndexList*")
              set(TYPE "OPI_IndexList")
          endif()
          list(APPEND ARG_FUNCTION_BODY "${TYPE} ${NAME}")
          list(APPEND ARG_FUNCTION_BODY_WRAP "${TYPE} ${NAME}")
          if(REFCAST)
            set(NAME "*(static_cast<OPI::${REFCAST}*>(${NAME}))")
          elseif(TYPE_IS_ENUM)
              set(NAME "static_cast<OPI::PropagationMode>(${NAME})")
          elseif(${TYPE} STREQUAL "OPI_IndexList")
              set(NAME "static_cast<OPI::IndexList*>(${NAME})")
          elseif(${TYPE} STREQUAL "OPI_JulianDay")
              set(TYPE "")
              set(NAME "{epoch.day,epoch.usec}")
          endif()
          list(APPEND ARG_FUNCTION_CALL "${NAME}")
          list(APPEND ARG_FUNCTION_CALL_WRAP "${NAME}")
        endif()
      endforeach()
    endif()
    STRING(REPLACE ";" "," FUNCTION_BODY "${ARG_FUNCTION_BODY}")
    STRING(REPLACE ";" "," FUNCTION_BODY_WRAP "${ARG_FUNCTION_BODY_WRAP}")
    STRING(REPLACE ";" "," FUNCTION_CALL "${ARG_FUNCTION_CALL}")
    STRING(REPLACE ";" "," FUNCTION_CALL_WRAP "${ARG_FUNCTION_CALL_WRAP}")
endmacro()

macro(PARSE_FUNCTION)
    list(GET COMMAND_ARGS 0 FUNCTION_NAME)
    PARSE_ARGUMENTS(FUNCTION "OVERLOAD_ALIAS;RETURN;RETURN_PREFIX;ARGS" "" ${COMMAND_ARGS})
    set(FUNCTION_DO_RETURN_SUFFIX "")
    if(FUNCTION_RETURN)
      PARSE_TYPE( FUNCTION_RETURN)
      if(TYPE_IS_STRING)
         set(FUNCTION_RETURN "const char*")
         #set(FUNCTION_DO_RETURN_SUFFIX ".c_str()")
      endif()
      set(FUNCTION_DO_RETURN "return (${FUNCTION_RETURN})")
    else()
      set(FUNCTION_RETURN "void ")
      set(FUNCTION_DO_RETURN)
    endif()
    set(FUNCTION_CXX_NAME ${FUNCTION_NAME})
    if(FUNCTION_OVERLOAD_ALIAS)
      set(FUNCTION_NAME ${FUNCTION_OVERLOAD_ALIAS})
    endif()
    # parse function args
    set(ARG_FUNCTION_BODY "OPI_${CLASS_NAME} obj")
    set(ARG_FUNCTION_BODY_WRAP "OPI_${CLASS_NAME} obj")
    set(ARG_FUNCTION_CALL)
    set(ARG_FUNCTION_CALL_WRAP)
    PARSE_FUNCTION_ARGS(FUNCTION_ARGS)
    file(APPEND ${OUTPUT_HEADER_FILE} "OPI_API_EXPORT ${FUNCTION_RETURN} ${FUNCTION_PREFIX}${FUNCTION_NAME}(${FUNCTION_BODY});\n")
    file(APPEND ${OUTPUT_SOURCE_FILE} "${FUNCTION_RETURN} ${FUNCTION_PREFIX}${FUNCTION_NAME}(${FUNCTION_BODY})\n")
    file(APPEND ${OUTPUT_SOURCE_FILE} "{\n\t${FUNCTION_DO_RETURN}static_cast<OPI::${CLASS_NAME}*>(obj)->${FUNCTION_CXX_NAME}(${FUNCTION_CALL})${FUNCTION_DO_RETURN_SUFFIX};\n}\n")
    if(MAKE_STRINGWRAP)
      file(APPEND ${OUTPUT_HEADER_FILE} "OPI_API_EXPORT ${FUNCTION_RETURN} ${FUNCTION_PREFIX}${FUNCTION_NAME}StrLen(${FUNCTION_BODY_WRAP});\n")
      file(APPEND ${OUTPUT_SOURCE_FILE} "${FUNCTION_RETURN} ${FUNCTION_PREFIX}${FUNCTION_NAME}StrLen(${FUNCTION_BODY_WRAP})\n")
      file(APPEND ${OUTPUT_SOURCE_FILE} "{\n\t${FUNCTION_DO_RETURN}static_cast<OPI::${CLASS_NAME}*>(obj)->${FUNCTION_CXX_NAME}(${FUNCTION_CALL_WRAP})${FUNCTION_DO_RETURN_SUFFIX};\n}\n")
    endif()
endmacro()

macro(CHANGE_COMMAND NEW_COMMAND)
  if("${COMMAND}" STREQUAL "CONSTRUCTOR")
    PARSE_ARGUMENTS(CONSTRUCTOR "NAME;ARGS" "" ${COMMAND_ARGS})
    if(NOT CONSTRUCTOR_NAME)
      set(CONSTRUCTOR_NAME "${FUNCTION_PREFIX}create${CLASS_NAME}")
    else()
      set(CONSTRUCTOR_NAME "OPI_${CONSTRUCTOR_NAME}")
    endif()
    set(ARG_FUNCTION_BODY)
    set(ARG_FUNCTION_BODY_WRAP)
    set(ARG_FUNCTION_CALL)
    set(ARG_FUNCTION_CALL_WRAP)
    PARSE_FUNCTION_ARGS(CONSTRUCTOR_ARGS)
    file(APPEND ${OUTPUT_HEADER_FILE} "OPI_API_EXPORT OPI_${CLASS_NAME} ${CONSTRUCTOR_NAME}(${FUNCTION_BODY});\n")
    file(APPEND ${OUTPUT_SOURCE_FILE} "OPI_${CLASS_NAME} ${CONSTRUCTOR_NAME}(${FUNCTION_BODY})\n")
    file(APPEND ${OUTPUT_SOURCE_FILE} "{\n\treturn new OPI::${CLASS_NAME}(${FUNCTION_CALL});\n}\n")
  elseif("${COMMAND}" STREQUAL "DESTRUCTOR")
    PARSE_ARGUMENTS(CONSTRUCTOR "NAME;ARGS" "" ${COMMAND_ARGS})
    if(NOT CONSTRUCTOR_NAME)
      set(CONSTRUCTOR_NAME "${FUNCTION_PREFIX}destroy${CLASS_NAME}")
    else()
      set(CONSTRUCTOR_NAME "OPI_${CONSTRUCTOR_NAME}")
    endif()
    file(APPEND ${OUTPUT_HEADER_FILE} "OPI_API_EXPORT void ${CONSTRUCTOR_NAME}(OPI_${CLASS_NAME} obj);\n")
    file(APPEND ${OUTPUT_SOURCE_FILE} "void ${CONSTRUCTOR_NAME}(OPI_${CLASS_NAME} obj)\n")
    file(APPEND ${OUTPUT_SOURCE_FILE} "{\n\tdelete static_cast<OPI::${CLASS_NAME}*>(obj);\n}\n")
  elseif("${COMMAND}" STREQUAL "PREFIX")
    set(FUNCTION_PREFIX ${COMMAND_ARGS})
  elseif("${COMMAND}" STREQUAL "FUNCTION")
    PARSE_FUNCTION(${COMMAND_ARGS})
  endif()

  set(COMMAND ${NEW_COMMAND})
  set(COMMAND_ARGS)
endmacro()

macro(DECLARE_CLASS CLASS_NAME)
  if(NOT CLASS_${CLASS_NAME}_DECLARED)
    file(APPEND ${OUTPUT_HEADER_FILE} "typedef void* OPI_${CLASS_NAME};\n")
    set(CLASS_${CLASS_NAME}_DECLARED 1)
  endif()
endmacro()

macro(BIND_CLASS CLASS_NAME)
  file(APPEND ${OUTPUT_HEADER_FILE} "\n// ${CLASS_NAME} bindings\n")
  file(APPEND ${OUTPUT_SOURCE_FILE} "\n// ${CLASS_NAME} bindings\n")
  DECLARE_CLASS(${CLASS_NAME})
  set(CLASS_NAME ${CLASS_NAME})
  set(FUNCTION_PREFIX "OPI_${CLASS_NAME}_")
  set(COMMAND )
  set(COMMAND_ARGS)
  foreach(ARG ${ARGN})
    if(${ARG} STREQUAL "CONSTRUCTOR")
      CHANGE_COMMAND("CONSTRUCTOR")
    elseif(${ARG} STREQUAL "DESTRUCTOR")
      CHANGE_COMMAND("DESTRUCTOR")
    elseif(${ARG} STREQUAL "FUNCTION")
      CHANGE_COMMAND("FUNCTION")
    elseif(${ARG} STREQUAL "PREFIX")
      CHANGE_COMMAND("PREFIX")
    else()
      LIST(APPEND COMMAND_ARGS ${ARG})
    endif()
  endforeach()
  CHANGE_COMMAND("")
endmacro()

string(REPLACE " " ";" FILES "${PROCESS_FILES}")
foreach(PROCESS_FILE ${FILES})
  file(APPEND ${OUTPUT_HEADER_FILE} "// Source File: ${PROCESS_FILE}\n")
  include(${PROCESS_FILE})
  file(APPEND ${OUTPUT_HEADER_FILE} "\n")
endforeach()


file(APPEND ${OUTPUT_HEADER_FILE} "#ifdef __cplusplus\n}\n#endif\n#endif\n\n")
file(APPEND ${OUTPUT_SOURCE_FILE} "}\n\n")
