module docgenerator;
import std::io;
import std::io::file;
import std::core::mem;
import libc;
import std::collections::list;

fault MyResult
{
	T_OVERFLOW,
    T_WRONG_TYPE,
}

macro bool TokenList.has_next(&self) => self.len > 0;

macro bool TokenList.eof(&self) => !self.has_next() ? MyResult.T_OVERFLOW : self[0].type == TokenType.EOF;

macro Token TokenList.peek(&self, int offset = 0) => !self.has_next() ? MyResult.T_OVERFLOW : self[offset];

macro Token TokenList.next(&self) => !self.has_next() ? MyResult.T_OVERFLOW : self.pop_first();

macro Token TokenList.expect(&self, TokenType type){
	if(!self.has_next()){
		return MyResult.T_OVERFLOW;
	}
	else if(self[0].type != type) {
		return MyResult.T_WRONG_TYPE;
	}else {
		return self.pop_first();
	}
}

macro String TokenList.parse(&self){
	String mod;
	List(<String>) imps;

	while( !(self.eof()))
	{
		Token token = peek();
		if(token.type == TokenType.IMPORT){
			next();
			imps.push(self.parse_identifier());
		}else if (token.type == TokenType.MODULE){
			mod = next().value;
		}else{
			next();
		}
	}
	return mod;
}

macro String TokenList.parse_identifier(&self){
	String ident = self.next().value;
	while(self.has_next() && self.peek().TokenType == TokenType.COLON){
		self.expect(TokenType.COLON);
		self.expect(TokenType.COLON);
		Token other = self.expect(TokenType.IDENTIFIER);
		self = self + "::" + other.value;
	}
	return ident;
}

// macro String TokenList.parse_args(&self){
// 	self.expect(TokenType.OPEN_PAREN);

// 	while(self.peek().type != TokenType.CLOSE_PAREN){

// 	}

// 	self.expect(TokenType.CLOSE_PAREN);
// 	return "";
// }