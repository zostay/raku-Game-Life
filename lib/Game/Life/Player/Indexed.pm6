use v6;

use Game::Life::Board :board;
use Game::Life::Player;
use Game::Life::CellIndex;

role Game::Life::Player::Indexed does Game::Life::Player {
    has Game::Life::CellIndex $.cells .= new;

    method peek(Board:D $board) {
        my ($l, $t, $r, $b) = $board.living-extents;
        for $t..$b -> $y {
            for $l..$r -> $x {
                $!cells.raise($x, $y) if $board.cell($x, $y);
            }
        }
        $!cells.latch;
    }

    method next-turn-for-cell(
        Int:D $x,
        Int:D $y,
        Board:D $current,
        Board:D $next,
    ) {
        my $outcome = self.Game::Life::Player::next-turn-for-cell(
            $x, $y,
            $current,
            $next,
        );

        given $outcome {
            when :so  { $!cells.raise($x, $y) }
            when :!so { $!cells.kill($x, $y) }
        }
    }

    method start-next-turn() { $!cells.latch }
}
