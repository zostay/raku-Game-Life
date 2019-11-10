use v6;

use Game::Life::Board :board;

#| This class is a work in progress.
#|
#| This class performs the work of updating a board for each turn in Conway's
#| Game of Life.
class Game::Life {
    has Board $!current .= new;
    has Board $!next;

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

            $!current.raise($x, $y) if $v ~~ /\S/;
            $x++;
        }

        $!current.mutable = False;
    }

    #| Evaluate the current board and make updates to the next. The next board
    #| is a clone of the current board, so we just make changes.
    #|
    #| The C<$l>, C<$t>, C<$r>, C<$b> items are the top-left and botto-rigth
    #| corner coordinates of the grid to work on. This modifies the C<$.next>
    #| board in place so there's no return value.
    method next-turn-for(
        Int:D $l, #= The leftmost coordinate to update.
        Int:D $t, #= The topmost coordinate to update.
        Int:D $r, #= The rightmost coordinate to update.
        Int:D $b, #+ The bottommost coordinate to update.
    ) {
        for $l..$r -> $x {
            for $t..$b -> $y {

                # Is the cell currently live?
                my $live      = $!current.cell($x, $y);

                # How many live neighbors does it currently have?
                my $neighbors = [+] $!current.neighbors($x, $y);

                # If alive and has too many or too few neighbors, die.
                if $live && !(2 <= $neighbors <= 3) {
                    $!next.kill($x, $y);
                }

                # if dead and has the right number of neighbors, come to life.
                elsif !$live && $neighbors == 3 {
                    $!next.raise($x, $y);
                }
            }
        }
    }

    #| Sequentially generate the board state from the previous state.
    method next-turn() {
        $!next = $!current.clone(mutable => True);

        my ($l, $t, $r, $b) = $!current.living-extents;

        self.next-turn-for($l-1, $t-1, $r+1, $b+1);

        $!next.mutable = False;
        $!current = $!next;
    }

    #| Determine if the board is large and break it up into separate tasks. This
    #| will then perform the actual work for each section of the board using
    #| the C<method next-turn-for> method.
    method parallel-next-turn-for(
        Int:D $l, #= The leftmost coordinate to update.
        Int:D $t, #= The topmost coordinate to update.
        Int:D $r, #= The rightmost coordinate to update.
        Int:D $b, #+ The bottommost coordinate to update.
    ) {
        my @jobs = gather {
            if $r - $l > 20 {
                my $m = ceiling($l + ($r - $l)/2);
                #dd $l, $m, $r;

                take start self.parallel-next-turn-for($l, $t, $m - 1, $b);
                take start self.parallel-next-turn-for($m, $t, $r, $b);
            }

            elsif $b - $t > 20 {
                my $m = ceiling($t + ($b - $t)/2);
                #dd $t, $m, $b;

                take start self.parallel-next-turn-for($l, $t, $r, $m - 1);
                take start self.parallel-next-turn-for($l, $m, $r, $b);
            }

            else {
                take start self.next-turn-for($l, $t, $r, $b);
            }
        }

        await Promise.allof(@jobs);
    }

    #| Generate the next board from the previous state, but employ parallel
    #| computing methods to speed things up.
    method parallel-next-turn() {
        $!next = $!current.clone(mutable => True);

        my ($l, $t, $r, $b) = $!next.living-extents(:expand);

        await start self.parallel-next-turn-for($l-1, $t-1, $r+1, $b+1);

        $!next.mutable = False;
        $!current = $!next;
    }

    #| Return the current board. This board will always be immutable.
    method board() { $!current }
}
