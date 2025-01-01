package game
import rl "vendor:raylib"

import "core:fmt"
import "core:math/rand"
import "core:strconv"
import "core:strings"


ODIN_DEBUG := true
FPS: i32 = 30


Ghost :: struct {
	position:      [2]i32,
	direction:     [2]i32,
	direction_ind: int,
	path:          [dynamic][2]i32,
}

DFS_PATH :: struct {
	position: [2]i32,
	path:     [dynamic][2]i32,
}

Player :: struct {
	position:  [2]i32,
	direction: [2]i32,
}

Game :: struct {
	player: Player,
	ghosts: [4]Ghost,
	score:  i32,
	level:  [30][30]int,
	state:  GameState,
}

GameState :: enum {
	RUNNING,
	WON,
	LOST,
}

drawGame :: proc(game: Game) {
}


DFS :: proc(grid: [30][30]int, start: [2]i32, end: [2]i32) -> [dynamic][2]i32 {
	result: [dynamic][2]i32 = make([dynamic][2]i32)

	dd := [4][2]i32{{1, 0}, {0, -1}, {-1, 0}, {0, 1}}

	queue := make([dynamic]DFS_PATH)
	visited: map[[2]i32]int
	append(&queue, DFS_PATH{position = start})

	for len(queue) > 0 {
		temp: DFS_PATH = pop_front(&queue)
		if temp.position == end {
			result = temp.path
		} else {
			if visited[temp.position] == 0 {
				visited[temp.position] += 1
				for i := 0; i < len(dd); i += 1 {
					dx := dd[i][0] + temp.position[0]
					dy := dd[i][1] + temp.position[1]
					if grid[dx][dy] != 1 {
						temppath := make([dynamic][2]i32)
						append(&temppath, ..temp.path[:])
						append(&temppath, [2]i32{dx, dy})
						tempele := DFS_PATH {
							position = [2]i32{dx, dy},
							path     = temppath,
						}
						append(&queue, tempele)
					}
				}
			}
		}
	}

	return result
}

initGame :: proc(game: Game) -> Game {
    g := game

    g.score = 0

	g.state = GameState.RUNNING

    g.level = [30][30]int{}

    //initLevel(game)
    g.level[0]=  [30]int{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
    g.level[1]=  [30]int{1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1}
    g.level[2]=  [30]int{1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1}
    g.level[3]=  [30]int{1, 4, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 4, 1}
    g.level[4]=  [30]int{1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1}
    g.level[5]=  [30]int{1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1}
    g.level[6]=  [30]int{1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1}
    g.level[7]=  [30]int{1, 2, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 2, 1}
    g.level[8]=  [30]int{1, 2, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 2, 1}
    g.level[9]=  [30]int{1, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 1}
    g.level[10]= [30]int{1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1}
    g.level[11]= [30]int{1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1}
    g.level[12]= [30]int{1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1}
    g.level[13]= [30]int{1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1}
    g.level[14]= [30]int{1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1}
    g.level[15]= [30]int{1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1}
    g.level[16]= [30]int{1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1}
    g.level[17]= [30]int{1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1}
    g.level[18]= [30]int{1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1}
    g.level[19]= [30]int{1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1}
    g.level[20]= [30]int{1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1}
    g.level[21]= [30]int{1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1}
    g.level[22]= [30]int{1, 4, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 4, 1}
    g.level[23]= [30]int{1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 1}
    g.level[24]= [30]int{1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 1}
    g.level[25]= [30]int{1, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 1}
    g.level[26]= [30]int{1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1}
    g.level[27]= [30]int{1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1}
    g.level[28]= [30]int{1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1}
    g.level[29]= [30]int{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}

	g.player = Player{}
	g.player.position = [2]i32{13, 23}

	// whipe pgrid position where player is because otherwise we start with 1 point
	g.level[g.player.position[0]][g.player.position[1]] = 0

	g.ghosts = [4]Ghost{
    		Ghost{direction_ind = 0, direction = {-1, 0}, position = {14, 16}},
		Ghost{direction_ind = 0, direction = {-1, 0}, position = {14, 15}},
		Ghost{direction_ind = 0, direction = {-1, 0}, position = {14, 14}},
		Ghost{direction_ind = 0, direction = {-1, 0}, position = {14, 13}},
}

	path_to_player: []int

	dd := [4][2]i32{{1, 0}, {0, -1}, {-1, 0}, {0, 1}}

	// idea : ghosts run to the corners of the mapp then path to player is generated
    // creating ghosts and gettings paths for ghosts
	g.ghosts[0].path = DFS(g.level, g.ghosts[0].position, {1, 1})
	g.ghosts[1].path = DFS(g.level, g.ghosts[1].position, {1, 27})
	g.ghosts[2].path = DFS(g.level, g.ghosts[2].position, {27, 1})
	g.ghosts[3].path = DFS(g.level, g.ghosts[3].position, {28, 27})

    return g
}

FACTOR: i32 = 30

main :: proc() {
	rl.InitWindow(30 * FACTOR, 30 * FACTOR, "pacman")

	g := Game{}

    g = initGame(g)

    fmt.println("amount of ghosts:",len(g.ghosts))

	rl.SetTargetFPS(FPS)

	frames: i32 = 0

	for !rl.WindowShouldClose() {

		frames += 1

		// are we still gaming?
		available_score := 0

		// player movement
		px := g.player.position[0]
		py := g.player.position[1]
		if rl.IsKeyDown(rl.KeyboardKey.A) {
			px -= 1
		}
		if rl.IsKeyDown(rl.KeyboardKey.D) {
			px += 1
		}
		if rl.IsKeyDown(rl.KeyboardKey.W) {
			py -= 1
		}
		if rl.IsKeyDown(rl.KeyboardKey.S) {
			py += 1
		}
		if g.level[px][py] != 1 {
			g.player.position[0] = px
			g.player.position[1] = py

			if g.level[px][py] == 2 || g.level[px][py] == 4 {
				g.score += 1
				available_score -= g.level[px][py]
				g.level[px][py] = 0
			}
		}

		// GHOST MOVEMENT
		if frames % (FPS / 8) == 0 {
			for &ghost in g.ghosts {
				if len(ghost.path) > 0 && ghost.direction_ind < len(ghost.path) {
					ghost.position = ghost.path[ghost.direction_ind]
					ghost.direction_ind = (ghost.direction_ind + 1) // % len(ghost.path)
				}
				if ghost.direction_ind >= len(ghost.path) {
					ghost.path = DFS(g.level, ghost.position, g.player.position)
					ghost.direction_ind = 0
				}
				if ghost.position == g.player.position {
					g.state = GameState.LOST
				}
			}
		}

		rl.BeginDrawing()

		if g.state == GameState.RUNNING {
			// draw board
			for i: i32 = 0; i < len(g.level); i += 1 {
				for k: i32 = 0; k < len(g.level[i]); k += 1 {
					if g.level[i][k] == 1 {
						rl.DrawRectangle(i * FACTOR, k * FACTOR, FACTOR, FACTOR, rl.DARKBLUE)
					} else {
						if g.level[i][k] == 2 || g.level[i][k] == 4 {
							available_score += g.level[i][k]
							point_type: f32 = 3.0 if g.level[i][k] == 2 else 7.0
							rl.DrawRectangle(i * FACTOR, k * FACTOR, FACTOR, FACTOR, rl.BLACK)
							rl.DrawCircle(
								(i * FACTOR) + FACTOR / 2,
								(k * FACTOR) + FACTOR / 2,
								point_type,
								rl.WHITE,
							)
						} else {
							rl.DrawRectangle(i * FACTOR, k * FACTOR, FACTOR, FACTOR, rl.BLACK)
						}
					}
				}
			}


			// draw GHOSTS
			for i: int = 0; i < len(g.ghosts); i += 1 {
				ghost := g.ghosts[i]
				rl.DrawRectangle(
					ghost.position[0] * FACTOR,
					ghost.position[1] * FACTOR,
					FACTOR,
					FACTOR,
					rl.GREEN,
				)
			}


			// draw player
			rl.DrawRectangle(
				g.player.position[0] * FACTOR,
				g.player.position[1] * FACTOR,
				FACTOR,
				FACTOR,
				rl.YELLOW,
			)

			// draw score
			buf: [8]u8
			result := strconv.itoa(buf[:], int(g.score))
			score_text: []string = {"SCORE : ", result}
			score_text_final := strings.clone_to_cstring(strings.concatenate(score_text[:]))
			rl.DrawText(score_text_final, 12 * FACTOR, 3 * FACTOR, FACTOR, rl.GREEN)
		}

        fmt.println(g.state)
        if g.state == GameState.LOST {
            rl.ClearBackground(rl.BLUE)
			rl.DrawText("YOU LOST", 12 * FACTOR, 3 * FACTOR, FACTOR, rl.GREEN)
            if rl.IsKeyDown(rl.KeyboardKey.R) {
                g = Game{}
                g = initGame(g)
                g.state = GameState.RUNNING
                available_score = 99
            }
        }

        if g.state == GameState.WON {
            rl.ClearBackground(rl.BLUE)
			rl.DrawText("YOU WON", 12 * FACTOR, 3 * FACTOR, FACTOR, rl.GREEN)
        }
		rl.EndDrawing()

		if available_score == 0 && g.state == GameState.RUNNING{
			g.state = GameState.WON
		}
	}

	rl.CloseWindow()


}
