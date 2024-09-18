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

fn void render_task(Task task, int width){
	DString to_render;
	to_render.clear();
	to_render.append("[ ] ");
	
	if(task.len < width){
		to_render.append(task);
		for(int x = 0; x < width - task.len-6; x++){
			to_render.append_char(' ');
		}
	}else{
		for(int y = 0; y < width; y++){
			to_render.append_char(task[y]);
		}
	}
	tc::print(to_render.zstr_view());
}

fn void render(Screen* screen){
	int width = screen.term_dim.x - 5; // screen width - 3 ("[ ] ") + line ending
	int current = screen.curs_pos.y;
	if(screen.finished.len() > 0){
		width = (int) math::floor(width/2f);
	}
	tc::clear_screen();
	

	usz cols = screen.in_prog.len();
	if(cols < screen.finished.len()) cols = screen.finished.len();
	for(int i = 0; i < cols; i++){
		screen.update(0, i);
		if(i < screen.in_prog.len()){
			render_task(screen.in_prog.get(i), width);
		}
		
		if(i < screen.finished.len()) {
			if(i >= screen.in_prog.len()){
				for(int z = 0; z < width; z++){
					tc::print(" ");
				}
			}

			// tc::print(" ");
			render_task(screen.finished.get(i), width);
		}
		tc::print("\n");
	}
	screen.update(1, current);
}

fn int main(String[] args){
	@alt_screen(;Screen screen){
		//prepopulate the checklist (for Testing!)
		screen.in_prog.push({.task = "Clean bedroom!"});
		screen.in_prog.push({.task = "Do dishes!"});
		screen.in_prog.push({.task = "Reaaaaaaaaaaaaaaally reaaaaaaaaaaaaaaaally REAAAAAAAAAAAAAAAAAAAAAALLY LOOOOONG taaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaask!!!"});
		int input;
		while(true){
			//render checklist
			render(&screen);
			tc::printfn_at(1, screen.term_dim.y-2, "%s", input);
			//move cursor arrow keys between check boxes
			input = tc::getch();
			if(input == Q){ break;}
			else if(input == UP_ARROW && screen.curs_pos.y != 0 && screen.in_prog.len() > 0) {
				screen.move_vec2(screen::CURSOR_UP);
			} else if(input == DOWN_ARROW  && screen.curs_pos.y != screen.in_prog.len()-1 && screen.in_prog.len() > 0) {
				screen.move_vec2(screen::CURSOR_DOWN);
			} else if (input == 13 && screen.in_prog.len() > 0){
				int y = screen.curs_pos.y;
				if(y-1 < 0) y = 0;
				screen.update(screen.curs_pos.x, y-1);
				Task task = screen.in_prog.get(y);
				screen.in_prog.remove_at(y);
				screen.finished.push(task);
			}
		}
	};
	return 0;
}

fn int old_main(String[] args)
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
