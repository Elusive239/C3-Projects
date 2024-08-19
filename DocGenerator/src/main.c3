module docgenerator;
import libc;
import std::io;
import std::io::file;
import std::core::mem;
import std::collections::list;
import std::io::path;

/*
	for each arg
	1. clear "currentDirPath"
	2. append CWD with current arg to "currentDirPath"
	3. tokenize / parse
	4. create markdown file with current arg[0:^3].md (current arg.md instead of current arg.c3)
	5. write parsed tokens to above file, then close it.
*/

fn String to_markdown(Path path){
	@pool(){
		return tokenize(path.str_view()).parse().evaluate_format();
	};
}

fn int generate_doc(Path cwd, String project_name = ""){
	@pool(){
		//create output folder
		Path folder;
		if(project_name.len != 0){
			folder = cwd.tappend(project_name.tconcat("_docs"))!!;
		}else{
			folder = cwd.tappend("generated_docs")!!;
		}
		if(!path::is_dir(folder)){
			path::mkdir(folder)!!;
		}
		path::chdir(folder)!!;

		PathList path_list = find_by_extension(cwd, ".c3", true);
		foreach(Path found : path_list){
			String output = to_markdown(found);
			File! file = io::file::open(found.basename()[0:^3].tconcat(".md"), "w");
			if(catch anyfault f = file){
				io::printn("Couldn't open file to output markdown");
				return -1;
			}
			file.write(output)!!;
			file.close()!!;
		}
	};
	return 0;
}


//This is the main function. You will never guess what this does!
fn int main(String[] args)
{
	path::Path cwd = std::io::path::getcwd()!!;
	
	return generate_doc(cwd);
}