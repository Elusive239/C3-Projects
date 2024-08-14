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

fn PathList find_by_extension(Path directory, String extension, bool recursive = false){
	io::printfn("Checking Dir => %s", directory);

	PathList list;
	PathList currentDirectory = std::io::path::ls(directory)!!; defer currentDirectory.free();
	DString dstr; defer dstr.free();
	foreach(Path currentPath : currentDirectory){
		dstr.clear();
		dstr.appendf( std::io::path::PREFERRED_SEPARATOR == 92 ? "%s\\%s" : "%s/%s", directory, currentPath);
		
		if(std::io::path::is_dir(currentPath) && recursive){
			PathList foundFiles = find_by_extension(std::io::path::new(dstr.str_view())!!, extension, recursive); defer foundFiles.free();
			while(foundFiles.len() > 0 ) list.push(foundFiles.pop()!!);
			continue;
		}

		String strView = currentPath.path_string;
		if(strView.len > 3 && strView.contains(".c3"))  list.push(std::io::path::new(dstr.str_view())!!);
		currentPath.free();
	}
	return list;
}