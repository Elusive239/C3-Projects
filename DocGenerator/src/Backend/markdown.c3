module docgenerator;
import std::io;
import std::io::file;
import std::core::mem;
import libc;
import std::collections::list;
import std::sort;

macro DString* DString.new_line(&self){
	self.append("  \n");
	return self;
}

macro DString* DString.h1(&self, String s){
    self.appendfn("# %s", s);
    return self;
}

macro DString* DString.h2(&self, String s){
    self.appendfn("## %s", s);
    return self;
}

macro DString* DString.h3(&self, String s){
    self.appendfn("### %s", s);
    return self;
}

macro DString* DString.underline1(&self, String s = " "){
     if(s.trim().len == 0){
        self.append("\n=======\n");
    }else{
        self.appendfn("%s\n=======", s);
    }
    return self;
}

macro DString* DString.underline2(&self, String s = " "){
    if(s.trim().len == 0){
        self.append("\n-------\n");
    }else{
        self.appendfn("%s\n-------", s);
    }
    return self;
}

macro DString* DString.underline3(&self, String s = " "){
    if(s.trim().len == 0){
        self.append("\n_____\n");
    }else{
        self.appendfn("%s\n_____", s);
    }
    return self;
}

macro DString* DString.numbered_list(&self, String[] s){
    foreach(index, String str : s){
	    self.appendfn("%d. %s", index+1, str, str);
	}
    return self;
}

macro DString* DString.dashed_list(&self, String[] s){
    foreach(String str : s){
	    self.appendfn("- %s", str, str);
	}
    return self;
}

macro DString* DString.comment(&self, String s = " "){
    if(s.len == 0) return self;

    String[] split = s.split("\n");
    foreach(String str : split){
        self.appendfn("\t%s  ", str.trim());
    }
    //self.underline3();
    return self;
}