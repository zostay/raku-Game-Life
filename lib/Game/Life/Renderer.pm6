use v6;

unit module Game::Life::Renderer;

use Game::Life::Board :board;

sub render-text(Board $board) is export {
    my ($l, $t, $r, $b) = $board.living-extents;
    for ($t-1) .. ($b+1) -> $y {
        for ($l-1) .. ($r+1) -> $x {
            print $board.cell($x, $y) ?? "X" !! " ";
        }
        print "\n";
    }
}

use SDL2::Raw;

my $gwidth = 800;
my $gheight = 800;

my $window;
my $render;
my $event;

sub render-graphics(Board $board) is export {
    SDL_SetRenderDrawColor($render, 0, 0, 0, 0);
    SDL_RenderClear($render);

    while SDL_PollEvent($event) {
        if $event.type == QUIT {
            return True;
        }
    }

    SDL_SetRenderDrawColor($render, 255, 255, 255, 255);

    my $max-box-width  = $gwidth / $board.width;
    my $max-box-height = $gheight / $board.height;
    my $box-size       = $max-box-width min $max-box-height;

    my ($l, $t, $r, $b) = $board.living-extents;
    for ($t-1) .. ($b+1) -> $y {
        for ($l-1) .. ($r+1) -> $x {
            next unless $board.cell($x, $y);

            my $gx = $x - $l + 1;
            my $gy = $y - $t + 1;

            SDL_RenderFillRect($render,
                SDL_Rect.new(
                    $gx * $box-size,
                    $gy * $box-size,
                    $box-size,
                    $box-size,
                )
            );
        }
    }

    SDL_RenderPresent($render);

    return False;
}

sub initialize-graphics() is export {
    die "couldn't initialize SDL2: { SDL_GetError }"
        if SDL_Init(VIDEO) != 0;

    $window = SDL_CreateWindow(
        "Conway's Game of Life",
        SDL_WINDOWPOS_CENTERED_MASK,
        SDL_WINDOWPOS_CENTERED_MASK,
        $gwidth, $gheight,
        OPENGL
    );
    $render = SDL_CreateRenderer($window, -1, ACCELERATED +| PRESENTVSYNC);

    $event = SDL_Event.new;
}

