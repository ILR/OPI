set(OUTPUT_FILE ${OUTPUT_PATH}/opi_types.h)

file(WRITE ${OUTPUT_FILE}  "/******************************************************************\n")
file(APPEND ${OUTPUT_FILE} " * FILE GENERATED BY BUILD SYS\n")
file(APPEND ${OUTPUT_FILE} " * DO NOT EDIT MANUALLY\n")
file(APPEND ${OUTPUT_FILE} " *****************************************************************/\n")
file(APPEND ${OUTPUT_FILE} "#ifndef OPI_TYPES_H\n")
file(APPEND ${OUTPUT_FILE} "#define OPI_TYPES_H\n")
file(APPEND ${OUTPUT_FILE} "extern \"C\" {typedef void* OPI_Host;\n")
file(APPEND ${OUTPUT_FILE} "typedef void (*OPI_ErrorCallback)(OPI_Host host, int errorcode, void* privatedata);}\n")
file(APPEND ${OUTPUT_FILE} "namespace OPI\n")
file(APPEND ${OUTPUT_FILE} "{\n")
file(APPEND ${OUTPUT_FILE} "/// @addtogroup CPP_API_GROUP\n")
file(APPEND ${OUTPUT_FILE} "/// @{\n")
# Worker macros
macro(BEGIN_STRUCTURE TYPENAME)
file(APPEND ${OUTPUT_FILE} "\tstruct OPI_API_EXPORT ${TYPENAME}\n")
file(APPEND ${OUTPUT_FILE} "\t{\n")
endmacro()
macro(STRUCTURE_VARIABLE TYPE NAME)
file(APPEND ${OUTPUT_FILE} "\t\t${TYPE} ${NAME};\n")
if(NOT STRUCTURE_CONSTRUCTOR_ARGS)
  set(STRUCTURE_CONSTRUCTOR_ARGS "${TYPE} _${NAME}")
else()
  set(STRUCTURE_CONSTRUCTOR_ARGS "${STRUCTURE_CONSTRUCTOR_ARGS}, ${TYPE} _${NAME}")
endif()
if(NOT STRUCTURE_CONSTRUCTOR_INIT)
  set(STRUCTURE_CONSTRUCTOR_INIT "${NAME}(_${NAME})")
else()
  set(STRUCTURE_CONSTRUCTOR_INIT "${STRUCTURE_CONSTRUCTOR_INIT}, ${NAME}(_${NAME})")
endif()
endmacro()
macro(END_STRUCTURE TYPENAME)
file(APPEND ${OUTPUT_FILE} "\t\tOPI_CUDA_PREFIX ${TYPENAME}() {}\n")
file(APPEND ${OUTPUT_FILE} "\t\tOPI_CUDA_PREFIX ${TYPENAME}(${STRUCTURE_CONSTRUCTOR_ARGS}):${STRUCTURE_CONSTRUCTOR_INIT}\n")
file(APPEND ${OUTPUT_FILE} "\t\t{}\n")
file(APPEND ${OUTPUT_FILE} "\t};\n")
unset(STRUCTURE_CONSTRUCTOR_ARGS)
unset(STRUCTURE_CONSTRUCTOR_INIT)
endmacro()

macro(COMMENT COMMENT_TO_WRITE)
file(APPEND ${OUTPUT_FILE} "\t/// ${COMMENT_TO_WRITE}\n")
endmacro()

macro(BEGIN_ENUM TYPENAME)
file(APPEND ${OUTPUT_FILE} "\ttypedef int ${TYPENAME};\n")
file(APPEND ${OUTPUT_FILE} "\t/// enum declaration for ${TYPENAME}\n")
file(APPEND ${OUTPUT_FILE} "\tenum ENUM_${TYPENAME}\n\t{\n")
endmacro()
macro(ENUM_VALUE NAME VALUE)
file(APPEND ${OUTPUT_FILE} "\t\t${NAME} = ${VALUE},\n")
endmacro()
macro(END_ENUM TYPENAME)
file(APPEND ${OUTPUT_FILE} "\t\tENUM_${TYPENAME}_LAST_VALUE\n\t};\n")
endmacro()

macro(BIND_CLASS CLASS_NAME)
endmacro()

macro(DECLARE_CLASS CLASS_NAME)
endmacro()

string(REPLACE " " ";" FILES "${PROCESS_FILES}")
foreach(PROCESS_FILE ${FILES})
  file(APPEND ${OUTPUT_FILE} "// Source File: ${PROCESS_FILE}\n")
  include(${PROCESS_FILE})
endforeach()

file(APPEND ${OUTPUT_FILE} "/// @}\n")
file(APPEND ${OUTPUT_FILE} "}\n")

file(APPEND ${OUTPUT_FILE} "#endif"\n)
file(APPEND ${OUTPUT_FILE} "\n")
