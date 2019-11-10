use v6;

unit package Game::Life;

#| This is the abstraction for the game board. The board itself will expand in
#| any dimension as required to take new live cells. The cells are stored as
#| an array of arrays of booleans where True represents a live cell and False
#| represents a dead one.
#|
#| The board keeps a set of bounds, C<$.left>, C<$.right>, C<$.top>, and
#| C<$.bottom>, which record the size of the grid contained. This is the largest
#| possible area inside of which a live cell can be found.
class Board is export(:board) {
    has Array[Bool] @!columns;

    #| When set to C<False>, the board cannot be altered or expanded. Reading
    #| beyond the edges will always return a dead cell. Any attempt to change
    #| the board will cause an exception. The default is C<True> for mutability.
    has Bool $.mutable is rw = True;


    has Int $.left = 0;   #= The x coordinate of the leftmost possible live cell on the board.
    has Int $.top = 0;    #= The y coordinate of the topmost possible live cell on the board.
    has Int $.right = 0;  #= The x coordinate of the rightmost possible live cell on the board.
    has Int $.bottom = 0; #= The y coordinate of the bottommost possible live cell on the board.

    #| The width of the board currently instantiated.
    method width(--> Int:D) { $!right - $!left + 1 }
    method height(--> Int:D) { $!bottom - $!top + 1 }
    #= The height of the board currently instantiated.

    method TWEAK() {
        @!columns.push: Array[Bool].new(False);
    }

    #| Cloning this board will autmoaticaly perform a deep clone of the board
    #| itself.
    method clone(*%twiddles) {
        without %twiddles<columns> {
            %twiddles<columns> = Array[Array[Bool]].clone;
            for @!columns.kv -> $i, $v {
                %twiddles<columns>[$i] = $v.clone;
            }
        }

        callwith(|%twiddles);
    }

    method !expand-left($by) {
        #note "EXPAND-LEFT $by";
        @!columns.prepend(
            Array[Bool].new(False xx self.height) xx $by
        );
        $!left -= $by;
    }

    method !expand-right($by) {
        #note "EXPAND-RIGHT $by";
        @!columns.append(
            Array[Bool].new(False xx self.height) xx $by
        );
        $!right += $by;
    }

    method !expand-up($by) {
        #note "EXPAND-UP $by";
        for @!columns -> @cells {
            @cells.prepend(False xx $by);
        }
        $!top -= $by;
    }

    method !expand-down($by) {
        #note "EXPAND-DOWN $by";
        for @!columns -> @cells {
            @cells.append(False xx $by);
        }
        $!bottom += $by;
    }

    method !real-coords($x, $y) {
        if $!mutable {
            if $x < $!left {
                self!expand-left($!left - $x);
            }
            elsif $x > $!right {
                self!expand-right($x - $!right);
            }

            if $y < $!top {
                self!expand-up($!top - $y);
            }
            elsif $y > $!bottom {
                self!expand-down($y - $!bottom);
            }
        }

        ($x - $!left, $y - $!top);
    }

    method !lookup($x, $y) is rw {
        state $throw-away = False;

        if !$!mutable && ($x < $!left || $x > $!right || $y < $!top || $y > $!bottom) {
            $throw-away = False;
            return-rw $throw-away;
        }
        else {
            my ($rx, $ry) = self!real-coords($x, $y);
            return-rw @!columns[$rx][$ry];
        }
    }

    #| Returns whether the cell at C<($x, $y)> is alive or not.
    method cell(Int:D $x, Int:D $y --> Bool:D) { self!lookup($x, $y) }

    #| Brings the cell at C<($x, $y)> to life. Returns the previous state of the
    #| cell.
    #|
    #| Calling this method on an immutable board will cause an exception.
    method raise(Int:D $x, Int:D $y --> Bool:D) {
        die "This board has been marked immutable." unless $!mutable;
        #note "RAISE ($x, $y)";
        self!lookup($x, $y)++;
    }

    #| Kills the cell at C<($x, $y)>. Returns the state the cell had before.
    #|
    #| Calling this method on an immutable board will cause an exception.
    method kill(Int:D $x, Int:D $y --> Bool:D) {
        die "This board has been marked immutable." unless $!mutable;
        #note "KILL  ($x, $y)";
        self!lookup($x, $y)--;
    }

    #| Returns the liveness of the eight surrounding cells. If you care, the top
    #| neighbor is returned first followed by the top-right neighbor and
    #| continuing clockwise through the rest and ending iwth the top-left
    #| neighbor.
    method neighbors(Int:D $x, Int:D $y --> Seq:D) {
        gather {
            take self.cell($x, $y - 1);
            take self.cell($x + 1, $y - 1);
            take self.cell($x + 1, $y);
            take self.cell($x + 1, $y + 1);
            take self.cell($x, $y + 1);
            take self.cell($x - 1, $y + 1);
            take self.cell($x - 1, $y);
            take self.cell($x - 1, $y - 1);
        }
    }

    #| Returns the corner coordinates of the top-leftmost and bottom-rightmost
    #| live cells in the current board. If there are no live cells on the board,
    #| this will return (0, 0) for the corners.
    #|
    #| The value returned will always be a four element list:
    #|
    #|     ($left, $top, $right, $bottom)
    #|
    #| If the C<:$extend> option is set to C<True>, the board will expand by one
    #| in any direction such that the living extent bound is equal to the edge.
    #| This allows the game to avoid extending the board while working to
    #| calculate the state for the next turn.
    #|
    #| Attempting to extend an immutable boar will result in an exception.
    method living-extents(Bool :$extend = False --> List:D) {
        my ($ll, $lr, $lt, $lb) = ($!right, $!left, $!bottom, $!top);
        for $!left .. $!right -> $x {
            for $!top .. $!bottom -> $y {
                if self.cell($x, $y) {
                    $ll min= $x;
                    $lr max= $x;
                    $lt min= $y;
                    $lb max= $y;
                }
            }
        }

        return (0, 0, 0, 0)
            unless $ll < $!right && $lr > $!left && $lt < $!bottom && $lb > $!top;

        # Make sure the available extents are one wider than this
        if $extend {
            die "Cannot extend immutable board." unless $!mutable;

            if $ll == $!left   { self!expand-left(1)  }
            if $lt == $!top    { self!expand-up(1)    }
            if $lr == $!right  { self!expand-right(1) }
            if $lb == $!bottom { self!expand-down(1)  }
        }

        ($ll, $lt, $lr, $lb);
    }
}

