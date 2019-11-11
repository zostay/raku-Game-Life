use v6;

use Game::Life::Board :board;
use Game::Life::Player::Basic;

#| This is a demonstration of the divide-and-conquer strategy for playing
#| Conway's Game of Life. This is not the most efficient way to play the
#| simulation, but it demonstrates the method. It works similar to
#| L<Game::Life::Player::Basic>, but it splits a large game board up into
#| chunks and then schedules the work for each chunk to be performed as
#| separate tasks on separate threads.
class Game::Life::Player::DivideAndConquer is Game::Life::Player::Basic {
    #| Given the current boar, return the next. This will take teh slowest
    #| method for playing the ame and make it a little faster.
    method next-turn(Board:D $current --> Board:D) {
        my $next = $current.next-board;

        my ($l, $t, $r, $b) = $next.living-extents(:expand);

        await start self.parallel-next-turn-for($l-1, $t-1, $r+1, $b+1, $current, $next);

        $next;
    }

    #| Determine if the board is large and break it up into separate tasks. This
    #| will then perform the actual work for each section of the board using
    #| the C<method next-turn-for> method.
    method parallel-next-turn-for(
        Int:D $l,
        Int:D $t,
        Int:D $r,
        Int:D $b,
        Board:D $current,
        Board:D $next,
    ) {
        my @jobs = gather {
            if $r - $l > 20 {
                my $m = ceiling($l + ($r - $l)/2);
                #dd $l, $m, $r;

                take start self.parallel-next-turn-for($l, $t, $m - 1, $b, $current, $next);
                take start self.parallel-next-turn-for($m, $t, $r, $b, $current, $next);
            }

            elsif $b - $t > 20 {
                my $m = ceiling($t + ($b - $t)/2);
                #dd $t, $m, $b;

                take start self.parallel-next-turn-for($l, $t, $r, $m - 1, $current, $next);
                take start self.parallel-next-turn-for($l, $m, $r, $b, $current, $next);
            }

            else {
                take start self.next-turn-for($l, $t, $r, $b, $current, $next);
            }
        }

        await Promise.allof(@jobs);
    }
}
