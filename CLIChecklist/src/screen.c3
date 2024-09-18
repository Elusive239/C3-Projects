module screen;
import std::io;
import std::math;
import std::collections;
import tc;

def Vector2Int = int[<2>];
const Vector2Int CURSOR_UP = 	{0, -1};
const Vector2Int CURSOR_DOWN = 	{0, 1};
const Vector2Int CURSOR_LEFT = 	{-1, 0};
const Vector2Int CURSOR_RIGHT = {1, 0};

struct Task{
	inline String task;
}

def TaskList = List(<Task>);

struct Screen{
	Vector2Int curs_pos;
	Vector2Int term_dim;
	TaskList in_prog;
	TaskList finished;
}

/* 
	Records the terminals current cursor position and dimensions.
	Should only be called once, Ideally.
*/
fn void Screen.get(&self){
	int cx; int cy; int width; int height;
	tc::get_cursor(&cx, &cy);
	tc::get_cols_rows(&width, &height);
	self.curs_pos.x = cx;
	self.curs_pos.y = cy;
	self.term_dim.x = width;
	self.term_dim.y = height;
}

/*
	Sets the cursors position to the position held in the Screen.
*/
fn void Screen.cursor_set(&self) => tc::set_cursor(self.curs_pos.x, self.curs_pos.y);

/*
	Moves the cursor on the X and Y axis by the passed in amounts.
	Wraps around to the other sides of the terminal.
*/
fn void Screen.move_vec2(&self, Vector2Int dir) => self.move_int(dir.x, dir.y);
fn void Screen.move_int(&self, int x, int y) {
	x = math::clamp(x, -1, 1) + self.curs_pos.x;
	if(x < 0){
		x = self.term_dim.x -1;
	}else if (x >= self.term_dim.x){
		x = 0;
	}

	y = math::clamp(y, -1, 1) + self.curs_pos.y;
	if(y < 0){
		y = self.term_dim.y -1;
	}else if (y >= self.term_dim.y){
		y = 0;
	}
	self.update(x, y);
}

/*
	Updates the position of the mouse cursor in the Screen with the passed in values.
*/
fn void Screen.update(&self, int x, int y){
	self.curs_pos.x = x;
	self.curs_pos.y = y;
	self.cursor_set();
}

/*
	Moves the terminal to an alternate screen, and initializes our Screen object. 
	Exits alternate screen on macro Exit.
*/
macro @alt_screen(;@body(s)) @builtin
{
	tc::enter_alt_screen();
	tc::canon_off();
	tc::clear_screen();
	Screen screen;
	screen.get();
	defer tc::exit_alt_screen(); // injected defer
	defer tc::canon_on();
  	@body(screen);
}