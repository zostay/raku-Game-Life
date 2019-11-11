use v6;

use Game::Life::Board :board;
use Game::Life::Player;

#| This class is a work in progress.
#|
#| This class performs the work of updating a board for each turn in Conway's
#| Game of Life.
class Game::Life {
    has Game::Life::Player $.player is required;
    has Board $.board .= new;

    # has Str $.start-state = q:to/END_OF_DEFAULT_START_STATE/;
    #
    # XXXXX  XXXX   X   XXXXX   X   X   x
    #   X   x      X X    X    X X  X   X
    #   X   X     X   X   X   X   X X   X
    #   X    xxx  XXXXX   X   XXXXX XXXXX
    #   X       X X   X   X   X   X X   X
    #   X       X X   X   X   X   X X   X
    #   X       X X   X   X   X   X X   X
    # XXXXX XXXX  X   X XXXXX X   X X   X
    #
    # END_OF_DEFAULT_START_STATE

    #| This is a string representing the initial state to load into Conway's
    #| Game of Life. Every line of the string represents a line of the initial
    #| board. Each space a dead cell and each non-space a life cell.
    has Str $.start-state = q:to/END_OF_DEFAULT_START_STATE/;

                             X
                           X X
                 XX      XX            XX
                X   X    XX            XX
     XX        X     X   XX
     XX        X   X XX    X X
               X     X       X
                X   X
                 XX

    END_OF_DEFAULT_START_STATE

    method TWEAK() {
        my $x = 0;
        my $y = 0;
        for $!start-state.comb -> $v {
            if $v ~~ /\n/ {
                $y++;
                $x = 0;
                next;
            }

            $!board.raise($x, $y) if $v ~~ /\S/;
            $x++;
        }

        $!board.make-immutable;
    }


    #| Sequentially generate the board state from the previous state.
    method next-turn() {
        my $next = $!player.next-turn($!board);
        $next.make-immutable;
        $!board = $next;
    }
}
