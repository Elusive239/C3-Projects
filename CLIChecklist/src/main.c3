module clichecklist;
import std::io;
import std::math;
import tc;
import screen;

const int CTR_X = 24;
const int CTR_I = 9;
const int W = 119;
const int S = 115;
const int A = 97;
const int D = 100;
const int Q = 113;
const int BACKSPACE = 8;
const int UP_ARROW = 72;
const int DOWN_ARROW = 80;
const int LEFT_ARROW = 75;
const int RIGHT_ARROW = 77;

fn int main(String[] args)
{
	@alt_screen(;Screen screen){
		String title = "[CHECKLIST]";
		tc::printf_at((int)math::floor(screen.term_dim.x/2f - title.len/2f), 0 , "%s", title);
		while(true){
			tc::printf_at(0, 0, "%d, %d, %d, %d           ", screen.curs_pos.x, screen.curs_pos.y, screen.term_dim.x,screen.term_dim.y );
			int input = tc::getch();

			if(input <= 26){ //CTR Characters
				if(input == CTR_I){
					tc::clear_screen();
					screen.update(0, 0);
					while(CTR_X != input){
						tc::print_at(0, screen.term_dim.y-1, "Press CTR + X to exit insert mode.");
						input = tc::getch();
						if(input <= 26){
							if(BACKSPACE == input){
								tc::move_cursor(-1, 0);
								tc::print(" ");
								tc::move_cursor(-1, 0);
							}
						}
						else {
							tc::printf("%s", (char) input);
						}
					}
					tc::clear_screen();
				}
			}else{
				if(input == Q) break;
				if (input == W || input == UP_ARROW) screen.move_vec2(screen::CURSOR_UP);
				if (input == A || input == LEFT_ARROW) screen.move_vec2(screen::CURSOR_LEFT);
				if (input == S || input == DOWN_ARROW) screen.move_vec2(screen::CURSOR_DOWN);
				if (input == D || input == RIGHT_ARROW) screen.move_vec2(screen::CURSOR_RIGHT);
			}
			tc::printf_at(0, 1, "key: %s\t", input );
		}
	};
	return 0;
}
