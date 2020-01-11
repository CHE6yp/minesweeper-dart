import "dart:io";
import "dart:math";
import 'package:ansicolor/ansicolor.dart';

main(){
	var field = new Field();

	bool gameover = false;
	while (gameover==false)
	{

		stdout.writeln("Cell x:");
		int x = int.parse(stdin.readLineSync())-1;
		stdout.writeln("Cell y:");
		int y = int.parse(stdin.readLineSync())-1;
		stdout.writeln("Type f to toggle flag, type anything else to open cell");
		String action = stdin.readLineSync();

		if ("f" == action  || "F" == action){
			field.FlagCell(x,y); 
		}
		else{
			if (field.OpenCell(x,y)){
				gameover = GameOver();

				if (gameover==false){
					field = new Field();
				} else {
				}
			}
		}
	}
	stdout.writeln("Goodbye, asshole!");
}

bool GameOver(){
	stdout.writeln("Play again? Type y!");
	String again = stdin.readLineSync();

	return (again != "y" && again != "Y");
}

class Field{
	List<List<Cell>> cells;
	int size;
	int bombs;
	static int openCells;

	Field(){
		openCells = 0;

		stdout.writeln("Set field size");
		size = int.parse(stdin.readLineSync()) ?? 5;
		stdout.writeln("Set mine count");
		bombs = int.parse(stdin.readLineSync()) ?? 4;

		cells = List<List<Cell>>.generate(
			size, (i) => List<Cell>.generate(size, (j) => new Cell()));

		PlaceBombs();
		CountCells();
	}



	void PlaceBombs(){
		Random r = new Random(new DateTime.now().microsecond);

		int x = bombs;
		while (x>0){
			if (cells[r.nextInt(size)][r.nextInt(size)].PlaceBomb())
				x--;
		}
	}

	void CountCells(){
		for (int y = 0;y<size;y++){
			for (int x = 0;x<size;x++)
			{
				if (x!=0){
					if (cells[y][x-1].bomb) cells[y][x].number++;

					if (y!=0){
						if (cells[y-1][x-1].bomb) cells[y][x].number++;
					}
					if (y!=size-1){
						if (cells[y+1][x-1].bomb) cells[y][x].number++;
					}
				}
				if (x!=size-1){
					if (cells[y][x+1].bomb) cells[y][x].number++;

					if (y!=0){
						if (cells[y-1][x+1].bomb) cells[y][x].number++;
					}
					if (y!=size-1){
						if (cells[y+1][x+1].bomb) cells[y][x].number++;
					}
				}

				if (y!=0){
					if (cells[y-1][x].bomb) cells[y][x].number++;
				}
				if (y!=size-1){
					if (cells[y+1][x].bomb) cells[y][x].number++;
				}
			}
		}
	}

	void DrawField(){

		AnsiPen bluePen = new AnsiPen()..xterm(019, bg: true);

		stdout.write("  ");
		int i = 0;
		for ( ;i<size;i++){
			stdout.write(bluePen((i+1).toString())+" ");
		}
		stdout.writeln();
		i = 0;
		for (List<Cell> list in cells){
			stdout.write(bluePen((++i).toString())+" ");
			for (Cell cell in list)
			{
				stdout.write(cell.value+" ");
			}
			stdout.writeln();
		}
	}

	//return true if gameover
	bool OpenCell(int x, int y){
		if (cells[y][x].Open())
		{
			if (x!=0){
				OpenCell(x-1,y);

				if (y!=0){
					OpenCell(x-1,y-1);
				}
				if (y!=size-1){
					OpenCell(x-1,y+1);
				}
			}
			if (x!=size-1){
				OpenCell(x+1,y);

				if (y!=0){
					OpenCell(x+1,y-1);
				}
				if (y!=size-1){
					OpenCell(x+1,y+1);
				}
			}

			if (y!=0){
				OpenCell(x,y-1);
			}
			if (y!=size-1){
				OpenCell(x,y+1);

			}
		}

		AnsiPen redPen = new AnsiPen()..red();
		AnsiPen greenPen = new AnsiPen()..green();
		if (cells[y][x].bomb)
		{
			DrawField();
			stdout.writeln(redPen('Oops! Gameover!'));
			return true;
		}
		if (openCells == size*size-bombs){
			DrawField();
			stdout.writeln(greenPen('Hooray! You won!'));
			return true;
		}
		return false;
	}

	void FlagCell(int x, int y){
		cells[y][x].Flag();
	}
}

class Cell {
	bool opened = false;
	bool flagged = false;
	bool bomb = false;
	int number = 0;

	AnsiPen redPen;
	AnsiPen greenPen;
	AnsiPen bluePen;
	AnsiPen yellowPen;


	String get value => opened ? bomb ? redPen("*"): (number == 0)? bluePen(number.toString()): greenPen(number.toString()) : flagged ? yellowPen("F"):"X";

	Cell(){
		redPen = new AnsiPen()..red();
		greenPen = new AnsiPen()..green();
		bluePen = new AnsiPen()..xterm(043);
		yellowPen = new AnsiPen()..yellow();
	}

	bool PlaceBomb()
	{
		if (bomb){
			return false;
		}
		else
		{
			bomb = true;
			return true;
		}
	}

	//возвращать тру если хотим чтобы дальше рекурсивно открывались соседи
	bool Open(){
		if (opened)
			return false;

		opened = flagged ? false : true;
		if (opened) Field.openCells++;

		//Может с бомбой тоже возвращать тру?
		if (opened && !bomb && number == 0)
			return true;
		else
			return false;
	}

	void Flag(){
		flagged = !flagged;
	}
}
