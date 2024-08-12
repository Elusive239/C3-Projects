module docgenerator;
import std::io;
import std::io::file;
import std::core::mem;
import libc;
import std::collections::list;

fault T_Fault
{
	T_OVERFLOW,
    T_WRONG_TYPE,
}

macro bool TokenList.has_next(&self) => self.len() > 0;

macro bool! TokenList.eof(&self) => !(self.has_next()) ?  T_Fault.T_OVERFLOW? : (self.first()!!.type == TokenType.EOF);

macro Token! TokenList.peek(&self, int offset = 0) {
	if(self.has_next()) return self.get(offset);
	return T_Fault.T_OVERFLOW?;
}

macro Token TokenList.next(&self) => self.pop_first()!!;

macro Token! TokenList.expect(&self, TokenType type){
	if(!self.has_next()){
		return T_Fault.T_OVERFLOW?;
	}
	else if(self.first()!!.type != type) {
		return T_Fault.T_WRONG_TYPE?;
	}else {
		return self.pop_first()!!;
	}
}

macro String TokenList.parse(&self){
	String mod; defer mod.free();
	List(<String>) imps; defer imps.free();
	List(<String>) funcs; defer funcs.free();
	DString str; defer str.free();
	DString comment; defer comment.free();
	while( self.has_next())
	{
		Token token = self.peek()!!;
		if(token.type == TokenType.IMPORT){
			self.next();
			imps.push(self.parse_identifier());
		}else if (token.type == TokenType.MODULE){
			self.next();
			mod = self.parse_identifier();
		}
		else if (token.type == TokenType.COMMENT){
			comment.clear();
			String com = self.next().value;
			comment.append(com);
		}
		else if (token.type == TokenType.FN || token.type == TokenType.MACRO){
			//fn type func_name (args) [BODY]
			str.clear();
			str.append("### ");
			str.append(self.parse_func());
			if(comment.len() != 0){
				str.append("  \n");
				str.append(comment);
				comment.clear();
			}
			str.appendf("\n%s", "________");
			funcs.push(str.copy_str());	//append to funcs
		}
		else{
			self.next();
		}		
	}
	mod.convert_ascii_to_upper();
	DString final; defer final.free();
	final.appendfn("%s\n=======\n", mod);
	final.appendfn("## Dependencies:");
	foreach(String cur : imps){
		final.appendfn("%s  ", cur);
	}
	final.appendfn("\n## Functions & Macros:");
	foreach(String cur : funcs){
		final.appendfn("%s  ", cur);
	}
	return final.copy_str();
}

macro String TokenList.parse_identifier(&self){
	DString ident; defer ident.free();
	ident.append(self.next().value);
	while(self.has_next() && self.peek()!!.type == TokenType.COLON){
		(void)self.expect(TokenType.COLON);
		(void)self.expect(TokenType.COLON);
		Token other = self.expect(TokenType.IDENTIFIER)!!;
		ident.append("::");
		ident.append(other.value);
	}
	return ident.copy_str();
}

macro String TokenList.parse_args(&self){
	self.expect(TokenType.OPEN_PAREN)!!;
	DString dstring; defer dstring.free();
	while( self.has_next() && self.peek()!!.type != TokenType.CLOSE_PAREN){
		if(self.peek()!!.type == TokenType.COMMA) dstring.appendf("%s ",self.next().value);
		String type = self.parse_identifier();
		String value = self.parse_identifier();
		dstring.appendf("%s %s", type, value);
	}
	self.expect(TokenType.CLOSE_PAREN)!!;
	// self.expect(TokenType.BODY)!!;
	return dstring.copy_str();
}

macro String TokenList.parse_func(&self){
	DString str; defer str.free();
	str.append(self.next().value);					//fn/macro
	str.appendf(" %s", self.parse_identifier()); 	//type
	str.appendf(" %s", self.parse_identifier());	//func name
	str.appendf(" (%s)", self.parse_args());   		//args
	return str.copy_str();
}		