use v6;

use Game::Life::Board :board;

#| A class implementing the Player role is able to transform a board from the
#| current turn to the next.
role Game::Life::Player {
    #| Given the current board, return the next. The given C<$board>
    #| containing the current board state is immutable and cannot be changed.
    method next-turn(Board:D $board --> Board:D) { ... }

    #| This method will calculate the next value of a particular cell. It
    #| performs operations on the C<$current> board and performs the
    #| modificatios in the C<$next> board.
    method next-turn-for-cell(
        Int:D $x,
        Int:D $y,
        Board:D $current,
        Board:D $next,
    ) {
        # Is the cell currently live?
        my $live      = $current.cell($x, $y);

        # How many live neighbors does it currently have?
        my $neighbors = [+] $current.neighbors($x, $y);

        # If alive and has too many or too few neighbors, die.
        if $live && !(2 <= $neighbors <= 3) {
            $next.kill($x, $y);
        }

        # if dead and has the right number of neighbors, come to life.
        elsif !$live && $neighbors == 3 {
            $next.raise($x, $y);
        }
    }
}
