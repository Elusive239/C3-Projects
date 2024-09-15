# MineSweeper

A small minesweeper game written to use the console. Includes C3 bindings for **tercontrol**, and a moddified version of the 
tercontrol library.

Currently, C3 does not support using header only libraries. Thus,
a conversion of some kind is required to a normal C library.

To Play:
1. Install the c3c compiler
2. In a terminal in the directory of the project, do `c3c run`

Dependencies:
[tercontrol](https://github.com/ZackeryRSmith/tercontrol.git)

Notes:
The below notes are for how to compile the C3 project without the C3 buildsystem. This project now uses the 
C3 build system so it's irrelavant, but i'll keep it in incase someone else wants to know how its done.

To compile the included [tercontrol.c](tercontrol.c) to use it with the bindings:
1. compile it with gcc: `gcc -c -fpic tercontrol.c -o tercontrol.o`
2. then use ar to put into a ".a" file: `ar rcs tercontrol.a tercontrol.o`

this is for compiling tercontrol for linux. for windows, use "x86_64-w64-mingw32-gcc" instead of "gcc", 
and replace ".a" with ".lib"

To Compile the main C3 project:

`c3c compile .\main.c3 .\tercontrol.c3 -l tercontrol`