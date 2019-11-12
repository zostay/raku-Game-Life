use v6;

use Game::Life::Board :board;
use Game::Life::Player;

#| This class is a work in progress.
#|
#| This class performs the work of updating a board for each turn in Conway's
#| Game of Life.
class Game::Life {
    #| The game must be given an initial player.
    has Game::Life::Player $.player is required;

    #| The initial board must be supplied. The board will always be immutable.
    has Board $.board is required where { .immutable };

    #| Sequentially generate the board state from the previous state.
    method next-turn() {
        my $next = $!player.next-turn($!board);
        $next.make-immutable;
        $!board = $next;
    }
}
