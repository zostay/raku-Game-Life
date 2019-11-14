use v6;

use Game::Life::Board :board;
use Game::Life::Player::Indexed;

class Game::Life::Player::BasicIndexed does Game::Life::Player::Indexed {
    method next-turn(Board:D $current --> Board:D) {
        self.start-next-turn;

        my $next = $current.next-board;

        my $living-cells   = $.cells.living-cells.Set;
        my $zeropopulated  = $.cells.living-cells.Set ∖ $.cells.neighboring-cells.Set;
        my $underpopulated = $.cells.neighboring-cells(1).Set;
        my $overpopulated  = $.cells.neighboring-cells(4..8).Set;
        my $quickening     = $.cells.neighboring-cells(3).Set;

        # note "LIVING: ", $living-cells;
        # note "ZERO:   ", $zeropopulated;
        # note "UNDER:  ", $underpopulated;
        # note "OVER:   ", $overpopulated;
        # note "QUICK:  ", $quickening;

        my $kill =
            $zeropopulated
            ∪
            ($living-cells ∩ $underpopulated)
            ∪
            ($living-cells ∩ $overpopulated)
            ;

        my $raise = $quickening ∖ $living-cells;

        # note "KILL:  ", $kill;
        # note "RAISE: ", $raise;

        # for flat $kill.keys, $raise.keys -> $c {
        #     self.next-turn-for-cell($c.x, $c.y, $current, $next);
        # }
        for $kill.keys -> $c {
            $next.kill($c.x, $c.y);
            $.cells.kill($c.x, $c.y);
        }

        for $raise.keys -> $c {
            $next.raise($c.x, $c.y);
            $.cells.raise($c.x, $c.y);
        }

        $next;
    }
}
