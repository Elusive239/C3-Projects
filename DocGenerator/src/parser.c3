module docgenerator;
import std::io;
import std::io::file;
import std::core::mem;
import libc;
import std::collections::list;

macro String read_file(String path){
    String! str = ( String) mem::new_array(char, std::io::file::get_size(path));
	//defer (void)str.free();
	String! read_file = (String) std::io::file::load_buffer(path, (char[])str);
	//defer (void) read_file.free();
	if(catch anyfault f = read_file){
		return "no file found.";
	}
    return read_file;
}

enum TokenType : int (String value){
	EOF = "EOF",
	IMPORT = "import",
	MODULE = "module",
	FN = "fn", 
	EMUM = "enum", 
	STRUCT = "struct", 
	OPEN_PAREN = "(", 
	CLOSE_PAREN = ")", 
    OPEN_BRACKET = "[",
    CLOSE_BRACKET = "]",
	OPEN_BODY = "{", 
	CLOSE_BODY = "}", 
	COMMENT = "//",
	MULTI_COMMENT_START = "/*",
	MULTI_COMMENT_END = "*/",
	SEMICOLON = ";",
	COLON = ":",
	OPTIONAL = "!",
	DOUBLE_QUOTE = "\"",
	COMMA = ",",
	PERIOD = ".",
	QUOTE = "\'",
	STRING_LIT = "",
	NUMBER_LIT = "",
	IDENTIFIER = "" //shouldn't get this unless its none of the above, so this stays empty.
}

macro bool char[].equals_string(char[] self, String other){
	if(self.len != other.len) return false;
	for(int i = 0; i < other.len; i++){
		if(self[i] != other[i]) return false;
	}
	return true;
}

macro bool char[].equals_char(char[] self, char other){
	if(self.len != 1) return false;
	return self[0] == other;
}

macro TokenType string_as_token(String value){
	foreach(TokenType type : TokenType.values){
		if(  type.value.equals_string(value)) return type;
	}
	return TokenType.IDENTIFIER;
}

macro TokenType char_as_token(char value){
	foreach(TokenType type : TokenType.values){
		if(  type.value.equals_char(value)) return type;
	}
	return TokenType.IDENTIFIER;
}

struct Token{
	String value;
	TokenType type;
	int line;
}

def TokenList = List(<Token>);

macro void TokenList.append_token(&self, String value, TokenType type, int lineNumber){
	Token token;
	token.value = value;
	token.type = type;
	token.line = lineNumber;
	self.push(token);
}

fn void TokenList.dump_tokens(&self, String path){
	io::File! file = std::io::file::open(path, "w")!!;
	DString str; 
	defer str.free();
	defer file.close()!!;
	foreach(Token t : self){
		str.appendf("Line %d -- \tValue: \'%s\' Type: \'%s\'\n", t.line, t.value, t.type.nameof);
	}
	file.write(str.str_view())!!;
}