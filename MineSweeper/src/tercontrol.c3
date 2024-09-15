module tc;
import std::io;

def IntPtr = int*;

/**
	CONSTANTS
**/

/* Base Colors */
const ZString NRM @if(!env::WIN32)= "\x1B[0m";	/* Normalize color */
const ZString NRM @if(env::WIN32) = ""; 			/* Normalize color */
const ZString RED 	= 	"\x1B[1;31m"; 		/* Red */
const ZString GRN 	= 	"\x1B[1;32m"; 		/* Green */
const ZString YEL 	= 	"\x1B[1;33m"; 		/* Yellow */
const ZString BLU 	= 	"\x1B[1;34m"; 		/* Blue */
const ZString MAG 	= 	"\x1B[1;35m"; 		/* Magenta */
const ZString CYN 	= 	"\x1B[1;36m"; 		/* Cyan */
const ZString WHT 	= 	"\x1B[1;37m"; 		/* White */

/* Bright Colors */		
const ZString B_NRM 	= 	"\x1B[0m";	  		/* Normalize Bright Color */
const ZString B_RED 	= 	"\x1B[0;31m"; 		/* Bright Red */
const ZString B_GRN 	= 	"\x1B[0;32m"; 		/* Bright Green */
const ZString B_YEL 	= 	"\x1B[0;33m"; 		/* Bright Yellow */
const ZString B_BLU 	= 	"\x1B[0;34m"; 		/* Bright Blue */
const ZString B_MAG 	= 	"\x1B[0;35m"; 		/* Bright Magenta */
const ZString B_CYN 	= 	"\x1B[0;36m"; 		/* Bright Cyan */
const ZString B_WHT 	= 	"\x1B[0;37m"; 		/* Bright White */

/* Background Colors */	
const ZString BG_NRM = 	"\x1B[40m"; 		/* Normalize Background Color */
const ZString BG_RED = 	"\x1B[41m"; 		/* Background Red */
const ZString BG_GRN = 	"\x1B[42m"; 		/* Background Green */
const ZString BG_YEL = 	"\x1B[43m"; 		/* Background Yellow */
const ZString BG_BLU = 	"\x1B[44m"; 		/* Background Blue */
const ZString BG_MAG = 	"\x1B[45m"; 		/* Background Magenta*/
const ZString BG_CYN = 	"\x1B[46m"; 		/* Background Cyan */
const ZString BG_WHT = 	"\x1B[47m"; 		/* Background White */

/* Additional formatting (ANSI) */	
const ZString BLD  	= 	"\x1B[1m"; 			/* Bold */
const ZString DIM  	= 	"\x1B[2m"; 			/* Dim */
const ZString ITAL 	= 	 "\x1B[3m"; 		/* Standout (italics) */
const ZString UNDR 	= 	 "\x1B[4m"; 		/* Underline */
const ZString BLNK 	= 	 "\x1B[5m"; 		/* Blink */
const ZString REV  	= 	"\x1B[7m"; 			/* Reverse */
const ZString INV  	= 	"\x1B[8m"; 			/* Invisible */

/**
	FUNCTIONS
**/

extern fn ZString color_id(uint cid, int l) @extern("tc_color_id");
extern fn ZString rgb(int r, int g, int b, int l) @extern("tc_rgb");
extern fn void get_cols_rows(IntPtr cols, IntPtr rows) @extern("tc_get_cols_rows");
extern fn void hide_cursor() @extern("tc_hide_cursor");
extern fn void show_cursor() @extern("tc_show_cursor");
extern fn void enter_alt_screen() @extern("tc_enter_alt_screen");
extern fn void exit_alt_screen() @extern("tc_exit_alt_screen");
extern fn void echo_off() @extern("tc_echo_off");
extern fn void echo_on() @extern("tc_echo_on");
extern fn void canon_off() @extern("tc_canon_off");
extern fn void canon_on() @extern("tc_canon_on");
extern fn void clear_partial(int x, int y, int width, int height) @extern("tc_clear_partial");
extern fn void get_cursor(IntPtr x, IntPtr y) @extern("tc_get_cursor");
extern fn void set_cursor(int x, int y) @extern("tc_set_cursor");
extern fn void move_cursor(int x, int y) @extern("tc_move_cursor");
extern fn void clear_screen() @extern("tc_clear_screen");
extern fn void clear_entire_line() @extern("tc_clear_entire_line");
extern fn void clear_line_till_cursor() @extern("tc_clear_line_till_cursor");
extern fn void clear_line_from_cursor() @extern("tc_clear_line_from_cursor");
extern fn void clear_from_top_to_cursor() @extern("tc_clear_from_top_to_cursor");
extern fn void clear_from_cursor_to_bottom() @extern("tc_clear_from_cursor_to_bottom");
extern fn void print(ZString s) @extern("tc_print");
extern fn int getch() @extern("tc_getch");

//My Additions

// thanks Christoffer L!
fn void! priv_putchar(void* data @unused, char c) @private 
{
  char[2] ch = { c, 0 };
  return print((ZString) &ch);
}

macro void printn(ZString s) => print((ZString)s.str_view().concat("\n"));

//Usage pulled from std::io::printf
macro void printf(String format, args...){
	std::io::Formatter formatter;
	formatter.init(&priv_putchar);
	formatter.vprintf(format, args)!!;
}

macro void printfn(String format, ...) => printf(format.concat("\n"), $vasplat);

macro void print_at(int x, int y, ZString str){
	int curX; 
	int curY;
	get_cursor(&curX, &curY);
	set_cursor(x, y);
	print(str);
	set_cursor(curX, curY);
}

macro void printn_at(int x, int y, ZString str) => print_at(x, y, (ZString)str.str_view().concat("\n"));

macro void printf_at(int x, int y, String format, ...){
	int curX; 
	int curY;
	get_cursor(&curX, &curY);
	set_cursor(x, y);
	printf(format, $vasplat);
	set_cursor(curX, curY);
}

macro void printfn_at(int x, int y, String format, ...) => printf_at(x, y, format.concat("\n"), $vasplat);