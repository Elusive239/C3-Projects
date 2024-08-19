module docgenerator;
import libc;
import std::io;
import std::io::file;
import std::core::mem;
import std::collections::list;
import std::io::path;

macro void String.replace(&self, char toReplace, char with){
	@pool(){
		ZString zstr = self.copy_zstr();
		for(int i = 0; i < self.len(); i++){
			if(zstr[i] == toReplace){
				self.set(i, with);
			}
		}
	};
}

fn bool char[].equals_string(char[] self, String other ) {
	if(self.len != other.len) return false;
	for(int i = 0; i < other.len; i++){
		if(self[i] != other[i]) return false;
	}
	return true;
}

fn bool char[].equals_char(char[] self, char other){
	if(self.len != 1) return false;
	return self[0] == other;
}

fn String read_file(String path ) {
	String read_file;
	@pool(){
    	String! str = ( String) mem::new_array(char, std::io::file::get_size(path));
		read_file = (String) std::io::file::load_buffer(path, (char[])str)!!;
	};
    return read_file;
}

fn PathList find_by_extension(Path directory, String extension, bool recursive = false, int depth = 10 ) {
	PathList list;
	if(depth <= 0) return list;
	@pool(){
		Path cwd = path::getcwd()!!;
		PathList ls = std::io::path::ls(directory)!!; 
		path::chdir(directory)!!;
		foreach(Path currentPath : ls){
			if(std::io::path::is_dir(currentPath) && recursive){
				PathList sublist = find_by_extension(currentPath, extension, recursive, depth-1);
				while(sublist.len() > 0) list.push(directory.append(sublist.pop()!!.str_view())!!);
			}else if (try ex = currentPath.extension() && ex == "c3") {
				list.push(directory.append(currentPath.str_view())!!);
			}
			currentPath.free();
		}
		path::chdir(cwd)!!;
	};
	return list;
}
