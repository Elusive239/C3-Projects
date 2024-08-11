module docgenerator;
import std::io;
import std::io::file;
import std::core::mem;
import libc;
import std::collections::list;

fn int add(int x, int y) => x+y;

fn int main(String[] args)
{
	String path = $$FILEPATH;//"main.c3";
	TokenList list = tokenize(path);
	defer list.free();

	io::printfn("Full List:\n\n%s", list.parse());

	io::printfn("Token Count: %d", list.len());
	list.dump_tokens("tokens.txt");
	return 0;
}