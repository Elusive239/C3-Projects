module docgenerator;
import std::io;
import std::io::file;
import std::core::mem;
import libc;
import std::collections::list;


usz index;

macro bool TokenList.has_next(&self, usz offset = 0) => index + offset < self.len();

macro bool TokenList.eof(&self) => !(self.has_next()) ?  true : (self.get(index).type == TokenType.EOF);

fn Token TokenList.peek(&self, usz offset = 0) {
	if(self.has_next()) return self.get(index + offset);
	Token eof;
	eof.type = TokenType.EOF;
	eof.value = "EOF";
	return eof;
}

fn Token TokenList.next(&self)  {
	return self.get(index++);
}

//we want this function to fail if we don't find a token we were expecting!
fn Token! TokenList.expect(&self, TokenType type){
	assert(self.has_next(), "[ERROR] TokenList out of tokens.");
	assert(self.peek().type == type, "[ERROR] expected type \'%s\', got \'%s\' ", self.peek().type, type);
	return self.next();
}

struct MDFormat{
	TokenType type;
	Token[] tokens;
	Token comment;
}

def MDFormater = List(<MDFormat>);

fn MDFormater TokenList.parse(&self){
	index = 0;
	MDFormater formater;
	while(self.has_next()){
		@pool(){
			MDFormat current;
			if(self.peek().type == TokenType.COMMENT){
				current.comment = self.next();
			}
			switch(self.peek().type){
				case TokenType.MODULE:
				case TokenType.IMPORT:
				case TokenType.IDENTIFIER:
				case TokenType.DEFINE:
				case TokenType.CONST:
					current.type = self.peek().type;
					current.tokens = self.next_arr(self.find_next(TokenType.SEMICOLON));
					formater.push(current);
				case TokenType.FN:
				case TokenType.MACRO:
				case TokenType.ENUM:
				case TokenType.FAULT:
				case TokenType.STRUCT:
					current.type = self.peek().type;
					current.tokens = self.next_arr(self.find_next(TokenType.BODY));
					formater.push(current);
				break;
				case TokenType.EOF: 
					current.type = TokenType.EOF; 
					formater.push(current); 
					self.next();
					break;
				default: self.next(); break;
			}
		};
	}
	return formater;
}

fn usz TokenList.find_next(&self, TokenType type){
	usz current = 1;
	while(current + index< self.len()){
		if(self.peek(current ).type == type){
			break;
		}
		current++;
	}
	assert(current + index < self.len(), "[ERROR] Next type not found! is your .c3 file correct?");
	return current;
}

fn Token[] TokenList.next_arr(&self, usz n){
	usz newIndex = n + index;
	assert(newIndex < self.len(), "[ERROR] n larger than size of TokenList.");
	Token[] arr;
	@pool(){
		TokenList tokens;
		for(usz i = index; i <= newIndex; i++){
			tokens.push(self.get(i));
		}
		arr = tokens.to_new_array();
	};
	index = newIndex + 1;
	return arr;
}