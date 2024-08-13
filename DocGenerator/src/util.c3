module docgenerator;
import libc;
import std::io;
import std::io::file;
import std::core::mem;
import std::collections::list;
import std::io::path;

macro void DString.replace(&self, char toReplace, char with){
	// io::printn("Replacing...");
	ZString zstr = self.copy_zstr();
	for(int i = 0; i < self.len(); i++){
		if(zstr[i] == toReplace){
			self.set(i, with);
		}
	}
	// io::printn("Done...");
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