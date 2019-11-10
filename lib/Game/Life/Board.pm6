use v6;

unit package Game::Life;

class Board is export(:board) {
    has Array[Bool] @.columns;

    has Bool $.mutable is rw = True;

    has $.origin-x = 0;
    has $.origin-y = 0;

    has $.left = 0;
    has $.top = 0;
    has $.right = 0;
    has $.bottom = 0;

    method width() { $!right - $!left + 1 }
    method height() { $!bottom - $!top + 1 }

    method TWEAK() {
        @!columns.push: Array[Bool].new(False);
    }

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

    method cell($x, $y) { self!lookup($x, $y) }

    method raise($x, $y) {
        die "This board has been marked immutable." unless $!mutable;
        #note "RAISE ($x, $y)";
        self!lookup($x, $y)++;
    }

    method kill($x, $y) {
        die "This board has been marked immutable." unless $!mutable;
        #note "KILL  ($x, $y)";
        self!lookup($x, $y)--;
    }

    method neighbors($x, $y) {
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

    method living-extents(Bool :$extend = False) {
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

