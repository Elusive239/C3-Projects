DOCGENERATOR
=======

## Contents
1. [Imports](#imports)   
2. [Functions & Macros](#functions--macros)   

## Imports
libc  
std::io  
std::io::file  
std::core::mem  
std::collections::list  
std::io::path  

## Functions & Macros
### fn void to_markdown (Path cwd)  
for each arg
	1. clear "currentDirPath"
	2. append CWD with current arg to "currentDirPath"
	3. tokenize / parse
	4. create markdown file with current arg[0:^3].md (current arg.md instead of current arg.c3)
	5. write parsed tokens to above file, then close it.
________  
### fn int main (String[] args)  
This is the main function. You will never guess what this does!
________  
