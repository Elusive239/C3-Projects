module docgenerator;
import std::io;
import std::io::file;
import std::core::mem;
import libc;
import std::collections::list;
import std::sort;


fn int get_type_priority(TokenType type){
	switch(type){
		case TokenType.MODULE: return 0;
		case TokenType.IMPORT: return 1;
		case TokenType.IDENTIFIER: return 3;
		case TokenType.DEFINE:return 5;
		case TokenType.CONST: return 4;
		case TokenType.FN: return 6;
		case TokenType.MACRO: return 7;
		case TokenType.ENUM: return 9;
		case TokenType.FAULT: return 10;
		case TokenType.STRUCT: return 11;
		default: return -1;
	}
}

macro int compare_to(MDFormat a, MDFormat b){
	int af = get_type_priority(a.type);
	int bf = get_type_priority(b.type);
	if(af == bf) return 0;
	return af < bf ? -1 :  1;
}

fn String MDFormater.evaluate_format( &self){
	io::printfn("what we got: %s ", self.first()!!);
	quicksort(self, (MDFormat a, MDFormat b) => compare_to(a, b));
	io::printfn("what we got post sort: %s ", self.first()!!);
	return "";
}