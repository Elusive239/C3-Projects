module screen;
import std::io;
import std::math;
import tc;

def Vector2Int = int[<2>];
const Vector2Int CURSOR_UP = 	{0, -1};
const Vector2Int CURSOR_DOWN = 	{0, 1};
const Vector2Int CURSOR_LEFT = 	{-1, 0};
const Vector2Int CURSOR_RIGHT = {1, 0};

struct Screen{
	Vector2Int curs_pos;
	Vector2Int term_dim;
}

fn void Screen.get(&self){
	int cx; int cy; int width; int height;
	tc::get_cursor(&cx, &cy);
	tc::get_cols_rows(&width, &height);
	self.curs_pos.x = cx;
	self.curs_pos.y = cy;
	self.term_dim.x = width;
	self.term_dim.y = height;
}

fn void Screen.cursor_set(&self) => tc::set_cursor(self.curs_pos.x, self.curs_pos.y);

fn void Screen.move_vec2(&self, Vector2Int pos) => self.move_int(pos.x, pos.y);
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

fn void Screen.update(&self, int x, int y){
	self.curs_pos.x = x;
	self.curs_pos.y = y;
	self.cursor_set();
}

macro @alt_screen(;@body()) @builtin
{
	tc::enter_alt_screen();
	tc::clear_screen();
	defer tc::exit_alt_screen(); // injected defer
  	@body();
}