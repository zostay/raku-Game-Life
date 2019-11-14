use v6;

use Game::Life::Board :board;
use Game::Life::Player::Indexed;

class Game::Life::Player::ParallelMapReduce does Game::Life::Player::Indexed {
    method next-turn(Board:D $current --> Board:D) {
        self.start-next-turn;

        my $next = $current.next-board;

        my $living-cells = $.cells.living;
        my $neighbors    = $.cells.neighbors;
        race for ($living-cells ∪ $neighbors).keys -> $c {
            if $living-cells{ $c } {
                if $c ∉ $neighbors || $neighbors{ $c } == 1 || $neighbors{ $c } > 3 {
                    $.cells.kill($c.x, $c.y);
                    $next.kill($c.x, $c.y);
                }
            }
            else {
                if $neighbors{ $c } == 3 {
                    $.cells.raise($c.x, $c.y);
                    $next.raise($c.x, $c.y);
                }
            }
        }

        $next;
    }
}
