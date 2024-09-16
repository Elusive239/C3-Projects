module clichecklist;
import std::io;
import std::math;
import tc;
import screen;

fn int main(String[] args)
{
	@alt_screen(){
		Screen screen;
		screen.get();
		String title = "[CHECKLIST]";
		tc::printf_at((int)math::floor(screen.term_dim.x/2f - title.len/2f), 0 , "%s", title);
		while(true){
			tc::printf_at(0, 0, "%d, %d, %d, %d     ", screen.curs_pos.x, screen.curs_pos.y, screen.term_dim.x,screen.term_dim.y );
			int c = tc::getch();
			if(c == 'q') break;
			if (c == 'w') screen.move_vec2(screen::CURSOR_UP);
			if (c == 'a') screen.move_vec2(screen::CURSOR_LEFT);
			if (c == 's') screen.move_vec2(screen::CURSOR_DOWN);
			if (c == 'd') screen.move_vec2(screen::CURSOR_RIGHT);
		}
	};
	return 0;
}
