build_all:
	echo "bulding snake..."
	odin build snake/snake.odin -file -out:./bin/snake
	echo "bulding pacman..."
	odin build pacman/pacman.odin -file -out:./bin/pacman

build_snake:
	echo "bulding snake..."
	odin build snake/snake.odin -file -out:./bin/snake

build_pacman:
	echo "bulding pacman..."
	odin build pacman/pacman.odin -file -out:./bin/pacman
