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
fn void to_markdown(Path cwd){
	PathList path_list = find_by_extension(cwd, ".c3", true, 2);
	foreach(Path found : path_list){
		@pool(){
			io::printfn("Tokenizing \'%s\':", found);
			TokenList list = tokenize(found.str_view());
			DString tmp = dstring::temp_with_capacity(found.basename().len + 1);
			tmp.appendf("%s%s", found.basename()[0:^3], ".txt");
			list.dump_tokens(tmp.str_view());
			tmp.clear();
			tmp.appendf("%s%s",found.basename()[0:^3], ".md");
			String output = list.parse();
			io::printfn("Parsing \'%s\':", found);
			io::printfn("Full List:\n%s", output);
			File! file = io::file::open(tmp.str_view(), "w");
			if(catch anyfault f = file){
				io::printfn("Couldn't open file \'%s\' to output markdown", tmp.str_view());
				continue;
			}
			file.write(output)!!;
			file.close()!!;
		};
	}
}


//This is the main function. You will never guess what this does!
fn int main(String[] args)
{
	path::Path cwd = std::io::path::getcwd()!!;
	//to_markdown(cwd);
	//if(!false) return 0;
	@pool(){
		TokenList list = tokenize(cwd.tappend("src").tappend("util.c3").str_view())!!;
		list.dump_tokens("tokens.txt");
		io::printfn("Token Count: %d", list.len());

		String output = list.parse();
		io::printfn("Full List:\n%s", output);
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