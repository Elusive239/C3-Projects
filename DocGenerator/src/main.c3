module docgenerator;
import std::io;
import std::io::file;
import std::core::mem;
import libc;
import std::collections::list;

fn int main(String[] args)
{
	// io::printn("Hello, World!");
	String path = $$FILEPATH;//"main.c3";
	String file = read_file(path);

	int lineCount = 1;
	TokenList list;
	DString dstring;
	defer list.free();
	defer dstring.free();
	defer file.free();

	int index = 0;
	while(index < file.len){
		char current = file[index++];
		if(current == '\n'){
			if(dstring.len() > 0){
				String copy = dstring.copy_str();
				list.append_token(copy, string_as_token(copy), lineCount);
				dstring.clear();
			}
			lineCount++;
			continue;
		}

		if(std::core::string::char_in_set(current, "0123456789")){
			if(dstring.len() > 0){
				String copy = dstring.copy_str();
				list.append_token(copy, string_as_token(copy), lineCount);
				dstring.clear();
			}
			while( index < file.len && std::core::string::char_in_set(current, "0123456789")){
				dstring.append(current);
				current =  file[index++];
			}
			list.append_token(dstring.copy_str(), TokenType.NUMBER_LIT, lineCount);
			dstring.clear();
			continue;
		}

		TokenType type = char_as_token(current);

		if(type == TokenType.DOUBLE_QUOTE || type == TokenType.QUOTE){
			if(dstring.len() > 0){
				String copy = dstring.copy_str();
				list.append_token(copy, string_as_token(copy), lineCount);
				dstring.clear();
			}
			current = file[index++];
			while( index < file.len && type != char_as_token(current)){
				dstring.append(current);
				current =  file[index++];
			}
			list.append_token(dstring.copy_str(), TokenType.STRING_LIT, lineCount);
			dstring.clear();
			continue;
		}

		if(type != TokenType.IDENTIFIER){
			if(dstring.len() > 0){
				String copy = dstring.copy_str();
				list.append_token(copy, string_as_token(copy), lineCount);
				dstring.clear();
			}
			list.append_token(type.value, type, lineCount);
			continue;
		}


		type = string_as_token(dstring.str_view());
		if(type == TokenType.COMMENT){
			dstring.clear();
			while( index < file.len && current != '\n'){
				dstring.append(current);
				current =  file[index++];
			}
			index++;
			list.append_token(dstring.copy_str()[0..^1], TokenType.COMMENT, lineCount);
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
					current =  file[index++];
				}
			}
			assert(dstring.str_view().contains(TokenType.MULTI_COMMENT_END.value));
			String copy = dstring.copy_str();
			list.append_token(copy[0..^2], TokenType.COMMENT, lineCount);
			lineCount++;
			dstring.clear();
			continue;
		}

		if(current == ' ' || current == '\r' || current == '\t') {
			if(dstring.len() > 0){
				String copy = dstring.copy_str();
				list.append_token(copy, string_as_token(copy), lineCount);
				dstring.clear();
			}
			continue;
		}
		dstring.append(current);
	}
	list.append_token(TokenType.EOF.value, TokenType.EOF, lineCount);
	// io::printn(dstring.str_view());
	io::printfn("Token Count: %d", list.len());
	list.dump_tokens("tokens.txt");
	return 0;
}