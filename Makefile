#
#	Makefile template
#
#	This is an example Makefile that can be used by anyone who is building
#	his or her own PHP extensions using the PHP-CPP library.
#
#	In the top part of this file we have included variables that can be
#	altered to fit your configuration, near the bottom the instructions and
#	dependencies for the compiler are defined. The deeper you get into this
#	file, the less likely it is that you will have to change anything in it.
#

#
#	Name of your extension
#
#	This is the name of your extension. Based on this extension name, the
#	name of the library file (name.so) and the name of the config file (name.ini)
#	are automatically generated
#

NAME				=	io

#
#	The name of the extension and the name of the .ini file
#
#	These two variables are based on the name of the extension. We simply add
#	a certain extension to them (.so or .ini)
#

EXTENSION 			=	${NAME}.so
INI 				=	${NAME}.ini

#
#	Compiler
#
#	By default, the GNU C++ compiler is used. If you want to use a different
#	compiler, you can change that here. You can change this for both the
#	compiler (the program that turns the c++ files into object files) and for
#	the linker (the program that links all object files into the single .so
#	library file. By default, g++ (the GNU C++ compiler) is used for both.
#

COMPILER			=	g++
LINKER				=	g++

#
#	Compiler and linker flags
#
#	This variable holds the flags that are passed to the compiler. By default,
# 	we include the -O2 flag. This flag tells the compiler to optimize the code,
#	but it makes debugging more difficult. So if you're debugging your application,
#	you probably want to remove this -O2 flag. At the same time, you can then
#	add the -g flag to instruct the compiler to include debug information in
#	the library (but this will make the final libphpcpp.so file much bigger, so
#	you want to leave that flag out on production servers).
#
#	If your extension depends on other libraries (and it does at least depend on
#	one: the PHP-CPP library), you should update the LINKER_DEPENDENCIES variable
#	with a list of all flags that should be passed to the linker.
#

#COMPILER_FLAGS		=	-Wall -c -O2 -std=c++11 -fpic -o
COMPILER_FLAGS		=	-Wall -c -O2 -fpic -o
LINKER_FLAGS		=	-shared -lusb-1.0
#LINKER_FLAGS		=	-shared -Wno-undef

#
#	Command to remove files, copy files and create directories.
#
#	I've never encountered a *nix environment in which these commands do not work.
#	So you can probably leave this as it is
#

RM	= rm -f
CP	= cp -f
MKDIR	= mkdir -p
LS	= ls -1


#
#	All source files are simply all *.cpp files found in the current directory
#
#	A builtin Makefile macro is used to scan the current directory and find
#	all source files. The object files are all compiled versions of the source
#	file, with the .cpp extension being replaced by .o.
#

SOURCES	= $(wildcard *.cpp)
OBJECTS	= $(SOURCES:%.cpp=%.o)
PHPCPP_OBJECTS	= \
		$(wildcard PHP-CPP/shared/zend/*.o)\
		$(wildcard PHP-CPP/shared/common/*.o)
PHPCPP_SOURCES	= \
		$(wildcard PHP-CPP/shared/common/*.d)\
		 $(wildcard PHP-CPP/shared/zend/*.d)
PHPCPP_LIB	= PHP_CPP/libphpcpp.so.2.1.0

#
#	From here the build instructions start
#
all:	${OBJECTS} ${PHPCPP_LIB} ${PHPCPP_OBJECTS} ${EXTENSION} ${LINKER_DEPENDENCIES}

${EXTENSION}:	${OBJECTS} ${PHPCPP_LIB} $(wildcard PHP-CPP/shared/zend/*.o) $(wildcard PHP-CPP/shared/common/*.o)
	${LINKER} -o $@ ${OBJECTS} $(wildcard PHP-CPP/shared/zend/*.o) $(wildcard PHP-CPP/shared/common/*.o) ${LINKER_FLAGS}

${OBJECTS}: ${SOURCES}
	./update-build-number.sh
	${COMPILER} ${COMPILER_FLAGS} $@ ${@:%.o=%.cpp}

${PHPCPP_LIB}: ${PHPCPP_OBJECTS} ${PHPCPP_SOURCES}
	cd PHP-CPP && make

install:
	./install-extension.sh ${NAME}

test: .TEST

.TEST:
	./test/webserver

clean:
	echo ${RM} ${EXTENSION} ${OBJECTS}
	${RM} ${EXTENSION} ${OBJECTS}
	#makecd PHP-CPP && make clean
