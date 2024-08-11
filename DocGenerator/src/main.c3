module docgenerator;
import libc;
import std::io;
import std::io::file;
import std::core::mem;
import std::collections::list;

fn int add(int x, int y) => x+y;

macro void hello() => io::printn("Hello, world!");

//This is the main function. You will never guess what this does!
fn int main(String[] args)
{
	String path = $$FILEPATH;//"main.c3";
	TokenList list = tokenize(path); defer list.free();
	list.dump_tokens("tokens.txt");
	io::printfn("Token Count: %d", list.len());

	String output = list.parse(); defer output.free();
	io::printfn("Full List:\n%s", output);
	File! file = io::file::open("TEST.md", "w");
	if(catch anyfault f = file){
		io::printn("Couldn't open file to output markdown");
		return -1;
	}
	file.write(output)!!;
	file.close()!!;
	return 0;
}