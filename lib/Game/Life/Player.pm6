use v6;

use Game::Life::Board :board;

#| A class implementing the Player role is able to transform a board from the
#| current turn to the next.
role Game::Life::Player {

    #| This will be called only once, prior to the first turn. This gives the
    #| player an initial look at the board that will be given on the first call
    #| to L<#method next-turn>.
    method peek(Board:D $board --> Board:D) { }

    #| Given the current board, return the next. The given C<$board>
    #| containing the current board state is immutable and cannot be changed.
    #|
    #| This must be implemented by classes implementing this role.
    method next-turn(Board:D $board --> Board:D) { ... }

    #| This method will calculate the next value of a particular cell. It
    #| performs operations on the C<$current> board and performs the
    #| modificatios in the C<$next> board.
    #|
    #| Returns C<True> if the cell was raised, C<False> if the cell was killed
    #| and C<Nil> if the cell is unchanged.
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
            return $next.kill($x, $y);
        }

        # if dead and has the right number of neighbors, come to life.
        elsif !$live && $neighbors == 3 {
            return $next.raise($x, $y);
        }

        else {
            return Nil;
        }
    }
}
