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

fn void render_task(Task task, int width, String checked){
	DString to_render;
	to_render.clear();
	to_render.append(checked);
	
	if(task.len < width){
		to_render.append(task);
		for(int x = 0; x < width - (task.len ); x++){
			to_render.append_char(' ');
		}
	}else{
		for(int y = 0; y < width; y++){
			to_render.append_char(task[y]);
		}
	}
	tc::print(to_render.zstr_view());
}

const String UNCHECKED = "[ ] ";
const String CHECKED = "[*] ";

fn void render_all(Screen* screen){
	int width = (int) math::floor(screen.term_dim.x/2f) - (UNCHECKED.len + 1 + CHECKED.len);
	// CHECKED/UNCHECKED + Task + Space + Task	
	usz cols = screen.in_prog.len();
	if(cols < screen.finished.len()) cols = screen.finished.len();
	for(int i = 0; i < cols && i < screen.term_dim.y-1; i++){
		if(i < screen.in_prog.len()){
			render_task(screen.in_prog.get(i), width, UNCHECKED);
		}
		tc::print(" ");
		if(i < screen.finished.len()) {
			if(i >= screen.in_prog.len()){
				for(int z = 0; z < width + UNCHECKED.len; z++){
					tc::print(" ");
				}
			}
			render_task(screen.finished.get(i), width, CHECKED);
		}
		tc::print("\n");
	}
}

fn void render_one(TaskList toPrint, int width, int height, String check){
	for(int i = 0; i < toPrint.len() && i < height; i++){
		render_task(toPrint.get(i), width - check.len, check);
	}
}

fn void render(Screen* screen){
	
	@at_screen_position(screen, 0, 0){
		tc::clear_screen();
		if(screen.finished.len() > 0 && screen.in_prog.len() > 0){
			render_all(screen);
		}else if (screen.finished.len() > 0){
			render_one(screen.finished, screen.term_dim.x, screen.term_dim.y, CHECKED);
		}else if (screen.in_prog.len() > 0){
			render_one(screen.in_prog, screen.term_dim.x, screen.term_dim.y, UNCHECKED);
		}
	};
}

fn int main(String[] args){
	@alt_screen(;Screen screen){
		screen.update(1,0);
		//prepopulate the checklist (for Testing!)
		screen.in_prog.push({.task = "Clean bedroom!"});
		screen.in_prog.push({.task = "Do dishes!"});
		screen.in_prog.push({.task = "Reaaaaaaaaaaaaaaally reaaaaaaaaaaaaaaaally REAAAAAAAAAAAAAAAAAAAAAALLY LOOOOONG taaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaask!!!"});
		screen.in_prog.push({.task = "Clean kitchen!"});
		screen.in_prog.push({.task = "Go to the Grocery!"});
		screen.in_prog.push({.task = "Order new toys from amazon"});
		screen.in_prog.push({.task = "Order new \"toys\" from amazon"});
		screen.in_prog.push({.task = "Clean bedroom again!"});
		
		//render checklist
		render(&screen);
		int input;
		while(true){
			tc::printfn_at(1, screen.term_dim.y-2, "%s             ", input); //DEBUG
			//move cursor arrow keys between check boxes
			input = tc::getch();
			if(input == Q){ break;}
			else if(input == UP_ARROW && screen.curs_pos.y != 0) {
				screen.move_vec2(screen::CURSOR_UP);
			} else if(input == DOWN_ARROW  && (screen.curs_pos.y != screen.in_prog.len()-1 || screen.curs_pos.y != screen.finished.len()-1) && screen.in_prog.len() > 0) {
				screen.move_vec2(screen::CURSOR_DOWN);
			} else if (input == 13 && screen.in_prog.len() > 0){
				check(&screen);
			} else if(input == CTR_X && (screen.finished.len() > 0 && screen.in_prog.len() > 0)){
				int middle = (int) math::floor(screen.term_dim.x / 2f);
				int pos = 1;
				if(!screen.checking){
					pos =  middle - (UNCHECKED.len-pos);
					screen.update(pos, screen.curs_pos.y);
					screen.checking = true;
				}else {
					screen.update(pos, screen.curs_pos.y);
					screen.checking = false;
				}
			}
		}
	};
	return 0;
}

fn void check(Screen* screen){
	int y = screen.curs_pos.y;
	if(y-1 < 0) y = 0;
	screen.update(screen.curs_pos.x, y-1);
	Task task = screen.in_prog.get(y);
	screen.in_prog.remove_at(y);
	screen.finished.push(task);
	render(screen);
}