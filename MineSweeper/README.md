# MineSweeper

A small minesweeper game written to use the console. Includes C3 bindings for **tercontrol**, and a moddified version of the 
tercontrol library.

Currently, C3 does not support using header only libraries. Thus,
a conversion of some kind is required to a normal C library.

Dependencies:
[tercontrol](https://github.com/ZackeryRSmith/tercontrol.git)

To compile the included [tercontrol.c](tercontrol.c) to use it with the bindings:
1. compile it with gcc: `gcc -c -fpic tercontrol.c -o tercontrol.o`
2. then use ar to put into a ".a" file: `ar rcs tercontrol.a tercontrol.o`

Notes:
this is for compiling tercontrol for linux. for windows, use "x86_64-w64-mingw32-gcc" instead of "gcc", 
and replace ".a" with ".lib"

To Compile the main C3 project:

`c3c compile .\main.c3 .\tercontrol.c3 -l tercontrol`