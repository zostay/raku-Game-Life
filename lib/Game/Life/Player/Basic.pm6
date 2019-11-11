use v6;

use Game::Life::Board :board;
use Game::Life::Player;

#| This is a simple and somewhat braindead Player that just iterates
#| through all the cells in the grid and calculates their next value for
#| the next game boar.
class Game::Life::Player::Basic does Game::Life::Player {
    #| Given the current board, return the next. This is about the slowest
    #| possible way to play Conway's Game of Life.
    method next-turn(Board:D $current --> Board:D) {
        my $next = $current.next-board;

        my ($l, $t, $r, $b) = $current.living-extents;

        self.next-turn-for($l-1, $t-1, $r+1, $b+1, $current, $next);

        $next;
    }

    #| Iterate through the extent given and update the board for those
    #| extents.
    method next-turn-for(
        Int:D $l,
        Int:D $t,
        Int:D $r,
        Int:D $b,
        Board:D $current,
        Board:D $next,
    ) {
        for $l..$r -> $x {
            for $t..$b -> $y {
                self.next-turn-for-cell($x, $y, $current, $next);
            }
        }
    }
}
