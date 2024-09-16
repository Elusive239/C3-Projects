module clichecklist;
import std::io;
import tc;


struct Screen{
	int[<2>] curs_pos;
	int[<2>] term_dim;
}

fn void Screen.get_screen(&self){
	int cx; int cy; int width; int height;
	tc::get_cursor(&cx, &cy);
	tc::get_cols_rows(&width, &height);
	self.curs_pos = {cx, cy};
	self.term_dim = {width, height};
}

fn void Screen.set_screen(&self) => tc::set_cursor(self.curs_pos.x, self.curs_pos.y);


macro @alt_screen(Screen screen;@body())
{
	screen.get_screen();
	tc::enter_alt_screen();
	tc::clear_screen();
	defer tc::exit_alt_screen(); // injected defer
  	@body();
}

fn int main(String[] args)
{
	Screen screen;
	@alt_screen(screen){
		String title = "[CHECKLIST]";
		tc::printfn("%s", title);
		while(true){
			tc::printf("%d, %d", screen.curs_pos.x, screen.curs_pos.y);
			if(tc::getch() == 'q') break;
			screen.curs_pos.y += 1;
			screen.set_screen();
		}
	};
	return 0;
}
