module docgenerator;
import std::io;
import std::io::file;
import std::core::mem;
import libc;
import std::collections::list;

enum TokenType : int (String value){
	EOF = "EOF",
	IMPORT = "import",
	MODULE = "module",
	FN = "fn", 
	MACRO = "macro",
	CONST = "const",
	ENUM = "enum", 
	FAULT = "fault",
	STRUCT = "struct", 
	OPEN_PAREN = "(", 
	CLOSE_PAREN = ")", 
    // OPEN_BRACKET = "[",
    // CLOSE_BRACKET = "]",
	OPEN_BODY = "{", 
	BODY = "",
	CLOSE_BODY = "}", 
	EQUAL = "=",
	LAMBDA = "=>",
	DEFINE = "def",
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

macro void TokenList.append_token_str(&self, String value, TokenType type, int lineNumber){
	Token token;
	token.value = value;
	token.type = type;
	token.line = lineNumber;
	self.push(token);
}

macro void TokenList.append_token_dstr(&self, DString* dstring, int lineNumber){
	if(dstring.len() > 0){
		String copy = dstring.copy_str();
		self.append_token_str(copy, string_as_token(copy), lineNumber);
		dstring.clear();
	}
}

fn void TokenList.dump_tokens(&self, String path){
	io::File! file = std::io::file::open(path, "w")!!;
	DString str; 
	defer str.free();
	defer file.close()!!;
	foreach(Token t : self){
		str.appendf("Line %d -- Type: \'%s\'\t\t\tValue: \'%s\' \n", t.line,t.type.nameof, t.value);
	}
	file.write(str.str_view())!!;
}

fn TokenList tokenize(String path){
	String file = read_file(path);defer file.free();

	int lineCount = 1;
	TokenList list;
	DString dstring;defer dstring.free();
	
	

	int index = 0;
	while(index < file.len){
		char current = file[index++];
		if(current == '\n'){
			list.append_token_dstr(&dstring, lineCount);
			lineCount++;
			continue;
		}

		if(std::core::string::char_in_set(current, "0123456789")){
			list.append_token_dstr(&dstring, lineCount);
			while( index < file.len && std::core::string::char_in_set(current, "0123456789")){
				dstring.append(current);
				current =  file[index++];
			}
			list.append_token_str(dstring.copy_str(), TokenType.NUMBER_LIT, lineCount);
			dstring.clear();
			continue;
		}

		TokenType type = char_as_token(current);

		if(type == TokenType.OPEN_BODY){
			list.append_token_dstr(&dstring, lineCount);
			int depth = 1;
			while(index < file.len && depth != 0){
				dstring.append(current);
				current = file[index++];
				if(char_as_token(current) == TokenType.OPEN_BODY){
					depth++;
				}else if(char_as_token(current) == TokenType.CLOSE_BODY){
					depth--;
				}
				
			}
			list.append_token_str(dstring.copy_str().trim()[1:^1].trim("\n\r "), TokenType.BODY, lineCount);
			dstring.clear();
			continue;
		}

		if(type == TokenType.DOUBLE_QUOTE || type == TokenType.QUOTE){
			list.append_token_dstr(&dstring, lineCount);
			current = file[index++];
			while( index < file.len && type != char_as_token(current)){
				dstring.append(current);
				current =  file[index++];
			}
			list.append_token_str(dstring.copy_str(), TokenType.STRING_LIT, lineCount);
			dstring.clear();
			continue;
		}

		if(type != TokenType.IDENTIFIER){
			list.append_token_dstr(&dstring, lineCount);
			list.append_token_str(type.value, type, lineCount);
			continue;
		}

		if(type == TokenType.EQUAL){
			if(file[current] != '>'){
				dstring.clear();
				while(index < file.len && current != ';'){
					current = file[index++];
					dstring.append(current);
				}
				list.append_token_str(dstring.copy_str(), TokenType.BODY, lineCount);
				dstring.clear();
				continue;
			}
		}


		type = string_as_token(dstring.str_view());

		if(type == TokenType.LAMBDA ){
			dstring.clear();
			while(index < file.len && current != ';'){
				current = file[index++];
				dstring.append(current);
			}
			list.append_token_str(dstring.copy_str(), TokenType.BODY, lineCount);
			dstring.clear();
			continue;
		}

		if(type == TokenType.COMMENT){
			dstring.clear();
			while( index < file.len && current != '\n'){
				dstring.append(current);
				current =  file[index++];
			}
			//index++;
			list.append_token_str(dstring.copy_str().trim(), TokenType.COMMENT, lineCount);
			lineCount++;
			dstring.clear();
			continue;
		}

		if(type == TokenType.MULTI_COMMENT_START){
			dstring.clear();
			while(index < file.len && !dstring.str_view().contains(TokenType.MULTI_COMMENT_END.value)){
				dstring.append(current);
				current =  file[index++];
				while(index < file.len && current == '\n'){
					lineCount++;
					dstring.append(current);
					current =  file[index++];
				}
			}
			assert(dstring.str_view().contains(TokenType.MULTI_COMMENT_END.value));
			String copy = dstring.copy_str();
			list.append_token_str(copy.trim()[0..^3].trim(), TokenType.COMMENT, lineCount);
			lineCount++;
			dstring.clear();
			continue;
		}

		if(current == ' ' || current == '\r' || current == '\t') {
			list.append_token_dstr(&dstring, lineCount);
			continue;
		}
		dstring.append(current);
	}
	list.append_token_str(TokenType.EOF.value, TokenType.EOF, lineCount);
	return list;
}