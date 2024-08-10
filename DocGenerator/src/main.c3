module docgenerator;
import std::io;
import std::io::file;
import std::core::mem;
import libc;
import std::collections::list;

enum TokenType : int (String value){
	IMPORT = "import",
	MODULE = "module",
	FN = "fn", 
	EMUM = "enum", 
	STRUCT = "struct", 
	LEFT_PAREN = "(", 
	RIGHT_PAREN = ")", 
	COMMENT = "//",
	MULTI_COMMENT_START = "/*",
	MULTI_COMMENT_END = "*/",
	SEMICOLON = ";",
	COLON = ":",
	IDENTIFIER = "" //shouldn't get this unless its none of the above, so this stays empty.
}

macro TokenType string_as_token(String value){
	TokenType! type = enum_by_name(TokenType, value);
	if(catch anyfault f = type) return TokenType.IDENTIFIER;
	return type;
}

macro TokenType char_as_token(char value){
	TokenType! type = enum_by_name(TokenType, $stringify(value));
	if(catch anyfault f = type) return TokenType.IDENTIFIER;
	return type;
}

struct Token{
	String value;
	TokenType type;
}

def TokenList = List(<Token>);


fn int main(String[] args)
{
	// io::printn("Hello, World!");
	String path = $$FILEPATH;//"main.c3";
	io::File! file = std::io::file::open(path, "r")!!;
	usz len = file.seek(0, END)!!;
	file.seek(0, SET)!!;
	std::io::file::get_size(path)!!;

	TokenList list;
	DString dstring;
	defer list.free();
	defer dstring.free();
	while(len-- >= 200){
		char current = file.read_byte()!!;
		TokenType type = char_as_token(current);
		if(type != TokenType.IDENTIFIER){
			Token token;
			token.value = dstring.copy_str();
			token.type = string_as_token(token.value);
			list.push(token);

			Token token2;
			token2.value = type.value;
			token2.type = type;
			list.push(token2);
			dstring.clear();
		}

		if(!current.is_blank()) dstring.append(current);

		type = string_as_token(dstring.str_view());
		if(type != TokenType.IDENTIFIER){
			Token token;
			token.value = type.value;
			token.type = type;
			list.push(token);
			dstring.clear();
		}else if(current.is_blank()){
			Token token;
			token.value = dstring.copy_str();
			token.type = type;
			list.push(token);
			dstring.clear();
		}

		//libc::putchar(current)!!;
	}
	io::printn(dstring.str_view());
	io::printfn("Token Count: %d", list.len());
	file.close()!!;
	return 0;
}
