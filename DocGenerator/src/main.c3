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
fn int to_markdown(Path cwd){
	@pool(){
		PathList path_list = find_by_extension(cwd, ".c3", true);
		foreach(Path found : path_list){
			TokenList list = tokenize(found.str_view());
			MDFormater formater = list.parse();

			String output = formater.evaluate_format();
			DString fpath;
			fpath.append(found.basename()[0:^3]);
			fpath.append(".md");
			File! file = io::file::open(fpath.str_view(), "w");
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
	to_markdown(cwd);
	if(!false) return 0;
	@pool(){
		TokenList list = tokenize(cwd.tappend("src").tappend("util.c3").str_view())!!;
		list.dump_tokens("tokens.txt");
		io::printfn("Token Count: %d", list.tokens.len());

		MDFormater formater = list.parse();
	
		String output = formater.evaluate_format();
		File! file = io::file::open("TEST.md", "w");
		if(catch anyfault f = file){
			io::printn("Couldn't open file to output markdown");
			return -1;
		}
		file.write(output)!!;
		file.close()!!;
	};
	return 0;
}