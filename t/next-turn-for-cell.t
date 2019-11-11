use v6;

use Test;
use Game::Life::Board :board;
use Game::Life::Player;

class TP does Game::Life::Player {
    method next-turn(Board:D $board --> Board:D) { }
}

my Board $init = make-board(:immutable, q:to/END_OF_SPINNER/);
XXX
END_OF_SPINNER

for -2, -1, 1, 2 -> $y {
    for -1..3 -> $x {
        nok $init.cell($x, $y), "initial ($x, $y) dead";
    }
}

nok $init.cell(-1, 0), 'initial (-1, 0) dead';
ok $init.cell(0, 0), 'initial (0, 0) live';
ok $init.cell(1, 0), 'initial (1, 0) live';
ok $init.cell(2, 0), 'initial (2, 0) live';
nok $init.cell(3, 0), 'initial (3, 0) dead';

my Board $next = $init.next-board;

for -1..3 -> $y {
    for -2..2 -> $x {
        TP.next-turn-for-cell($x, $y, $init, $next);
    }
}

for -2, 2 -> $y {
    for -1..3 -> $x {
        nok $next.cell($x, $y), "next ($x, $y) dead";
    }
}

for -1..1 -> $y {
    ok $next.cell(1, $y), "next (1, $y) live";

    for -1, 0, 2, 3 -> $x {
        nok $next.cell($x, $y), "next ($x, $y) dead";
    }
}

done-testing;
