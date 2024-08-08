
import libc;
import libc::termios;
import std::io;
import std::math;
import std::collections::list;
import std::math::random;
import std::core::mem;
import tercontrol;

enum CellState : int (char to_char) {
	NONE = '0',
	ONE ='1',
	TWO = '2',
	THREE = '3',
	FOUR = '4',
	FIVE = '5',
	SIX = '6',
	SEVEN = '7',
	EIGHT = '8',
	HIDDEN = '#',
	MARKED = 'X',
	BOMB = '@',
	EXPLODED = '*',
}

enum GameState : int{
	CONT,
	QUIT,
	WIN,
	LOSE
}

struct Game{
	Cell* board;
	int px;
	int py;
	int size;
	int mines;
}

struct Cell{
	CellState state;
	bool revealed;
	bool marked;
}

fn void Game.init(Game* game, int size, double difficulty){
	game.size = size;
	game.board = mem::new_array(Cell, (usz) size*size);
	game.px = game.size/2;
	game.py = game.size/2;
	game.mines = (int)( difficulty * (double) (game.size*game.size) );

	int count = 0;
	while(count != game.mines){
		int index = random::rand(game.size*game.size);

		if(game.board[index].state == CellState.BOMB) continue;

		game.board[index].state  = CellState.BOMB;
		count++;
	}

	for(int i = 0; i < game.size; i++){
		for(int y = 0; y < game.size; y++){
			int index = to_1d(i, y, game.size);
			if(game.board[index].state != CellState.BOMB) {
				CellState cnt = mine_count(game, i, y);
				game.board[index].state  = cnt;
			}
		}
	}
}

fn int Game.lose(Game* game){
	for(int i = 0; i < game.size*game.size; i++){
		if(game.board[i].state  == CellState.EXPLODED){
			return i;
		}
	}
	return -1;
}

fn void Game.render(Game* game, bool force_reveal){
	List(<char>) to_print;
	to_print.new_init();
	int pindex = to_1d(game.px, game.py, game.size);
	for(int i = 0; i < game.size; i++){
		to_print.push('\t');
		for(int y = 0; y < game.size; y++){
			int index = to_1d(i, y, game.size);

			CellState current = game.board[index].revealed || force_reveal ? game.board[index].state : CellState.HIDDEN;

			if(current == HIDDEN && game.board[index].marked){
				current = CellState.MARKED;
			}

			if((pindex - index) == 0){
				to_print.push('[');
				to_print.push(current.to_char);
				to_print.push(']');
			}else{
				to_print.push(' ');
				to_print.push(current.to_char);
				to_print.push(' ');
			}
		}
		to_print.push('\n');
	}
	io::printf("%s\n" , to_print.to_tarray());
	io::print("> ");
	to_print.free();
}

fn GameState Game.input(Game* game){
	//char c = (char) libc::getchar();
	char c = (char) tercontrol::tc_getch();
	int newX = game.px;
	int newY = game.py;

	switch(c){
		case 'w': newX --;
		case 's': newX ++;
		case 'a': newY --;
		case 'd': newY ++;
		case 'q': return GameState.QUIT;
		case ' ': 
		int ind = to_1d(game.px, game.py, game.size);
		if((ind > -1 && ind < game.size*game.size)){
			game.board[ind].revealed = true;
			if(game.board[ind].state  == CellState.BOMB) return GameState.LOSE;
		}
		case 'x':
		int ind = to_1d(game.px, game.py, game.size);
		game.board[ind].marked = !game.board[ind].marked;
	}
	//switching from libc::getchar to tercontrol::tc_getch requires this to fix output
	io::printn();

	game.px = math::clamp(newX, 0, game.size-1);
	game.py = math::clamp(newY, 0, game.size-1);

	return game.win();
}

fn GameState Game.win(Game* game){
	int count = (game.size*game.size) - game.mines;

	for(int i = 0; i < game.size*game.size; i++){
		if(game.board[i].revealed && game.board[i].state != CellState.BOMB){
			count--;
		}
	}
	return count == 0 ? GameState.WIN : GameState.CONT;
}

macro int to_1d(int x, int y, int dimensions){
	return y * dimensions + x;
}

fn CellState mine_count(Game* game, int x, int y){
	int count = 0;
  	for (int i = -1; i < 2; i++){
		int nx = x+i;
		if(nx >= 0 && nx < game.size ) for (int j = -1; j < 2; j++){
			int ny = y+j;

			if(nx == 0 && ny == 0) continue;

			if(ny >= 0 && ny < game.size ) {
				int index = to_1d(nx, ny, game.size);
				if(game.board[ index].state == CellState.BOMB){ 
					count++;
				}
			}
		}
  	}

	switch(count){
		case 0: return CellState.NONE;
		case 1: return CellState.ONE;
		case 2: return CellState.TWO;
		case 3: return CellState.THREE;
		case 4: return CellState.FOUR;
		case 5: return CellState.FIVE;
		case 6: return CellState.SIX;
		case 7: return CellState.SEVEN;
		case 8: return CellState.EIGHT;
	}

	return CellState.BOMB;
}

fn int main(){
	Game game;
	//recommended difficulties
	double difficulty = 0.12;
	//beginer = 0.12
	//intermediate = 0.15
	//hard = 0.17
	game.init(15, difficulty);
	game.render(false);
	GameState current = GameState.CONT;
	while(current == GameState.CONT){
		current = game.input();
		game.render(false);
		
		if(current == GameState.LOSE){
			int loss = game.lose();
			game.board[loss].state = EXPLODED;
			game.render(true);
			io::printf("You lose! Better luck next time!\n");
		}else if (current == GameState.WIN){
			io::printf("You win!\n");
		}
	}
	return 0;
}