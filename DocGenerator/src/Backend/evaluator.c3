module docgenerator;
import std::io;
import std::io::file;
import std::core::mem;
import libc;
import std::collections::list;
import std::sort;


fn usz get_type_priority (TokenType type) {
	switch(type){
		case TokenType.MODULE: return 0;
		case TokenType.IMPORT: return 1;
		case TokenType.DEFINE:return 2;
		case TokenType.IDENTIFIER: return 3;
		case TokenType.CONST: return 4;
		case TokenType.STRUCT: return 5;
		case TokenType.ENUM: return 6;
		case TokenType.FAULT: return 7;
		case TokenType.FUNCTION: return 8;
		case TokenType.MACRO: return 9;
		
		default: return -1;
	}
}

fn void MDFormater.insertion_sort (&self) {
	for(usz i = 0; i < self.len(); i++){
		for(usz y = i + 1; y < self.len(); y++){
			usz priorityA = get_type_priority(self.get(i).type);
			usz priorityB = get_type_priority(self.get(y).type);
			if(priorityB < priorityA){
				self.swap(i, y);
			}
		}
	}
}

fn String[] valid_types_as_string_array (TokenType[] types) {
	//TokenType[] types = {TokenType.MODULE, TokenType.IMPORT, TokenType.DEFINE, TokenType.IDENTIFIER, TokenType.CONST, TokenType.STRUCT, TokenType.ENUM, TokenType.FAULT, TokenType.FUNCTION, TokenType.MACRO};
	String[] arr = mem::alloc_array(String, types.len);
	@pool(){
		foreach(index, type : types){
			arr[index] = type.nameof.copy();
			arr[index].convert_ascii_to_lower();
			arr[index][0] =  arr[index][0].to_upper();
			
		}
	};
	return arr;
}

fn void MDFormater.change_state (&self, DString* file, TokenType current) {
	@pool(){
		TokenType[] types = {TokenType.IMPORT, TokenType.DEFINE, TokenType.IDENTIFIER, TokenType.CONST, TokenType.STRUCT, TokenType.ENUM, TokenType.FAULT, TokenType.FUNCTION, TokenType.MACRO};
		List(<TokenType>) found_types;
		found_types.temp_init();
		foreach(MDFormat format : self){
			if(format.type != TokenType.EOF && format.type != TokenType.MODULE) if(!found_types.contains(format.type)){
				found_types.push(format.type);
			}
		}
		
		switch(current){
			case TokenType.MODULE: 
			file.new_line().h2("Contents");
			
			String[] arr = valid_types_as_string_array(found_types.array_view());
			foreach(index, String s : arr){
				DString dstr;
				dstr.appendf("[%ss](#%ss)", s, s);
				arr[index] = dstr.copy_str();
			}
			file.numbered_list(arr);
			file.new_line();
			default: 

			usz state = get_type_priority(current) ;
			if(state > types.len ) return;

			file.h2(valid_types_as_string_array(types)[state-1].tconcat("s"));

		}
	};
}

fn String MDFormater.evaluate_format ( &self) {
	self.insertion_sort();
	DString file;
	@pool(){
		usz state = -1;
		if(self.first()!!.type == TokenType.MODULE){
			self.first()!!.tokens[1].value.convert_ascii_to_upper();
			file.underline1(self.first()!!.tokens[1].value);
		}
		
		foreach(MDFormat current : self){
			usz currentState = get_type_priority(current.type);

			if(state != currentState){
				state = currentState;
				self.change_state(&file, current.type);
			}

			switch(current.type){
				case TokenType.MODULE:
					continue;
				case TokenType.IMPORT:
					//append import
					// file.append("### ");
					for(int i = 1; i < current.tokens.len-1; i++){
						file.appendf( "%s", current.tokens[i].value);
					}
					file.new_line();
				default:
					file.append("### ");
					usz index = 0;
					while(index < current.tokens.len -1){
						file.appendf("%s ", current.tokens[index++].value);
					}
					file.new_line();
				//default: break;
			}
			//file.new_line();
			file.comment(current.comment.value);
		}
		//io::printn(file);
	};
	return file.str_view();
}