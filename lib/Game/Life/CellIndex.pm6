use v6;

class Game::Life::CellIndex {
    my class CT {
        has $.x;
        has $.y;
        method WHICH() { ValueObjAt.new("CT|$!x\0$!y") }
        method gist() { "«$!x,$!y»" }
    }

    has SetHash $!living    .= new;
    has BagHash $!neighbors .= new;

    has Lock $!lock .= new;

    has @!adds;
    has @!removes;

    method raise(Int:D $x, Int:D $y) {
        $!lock.protect: { @!adds.push: CT.new(:$x, :$y) }
    }

    method kill(Int:D $x, Int:D $y) {
        $!lock.protect: { @!removes.push: CT.new(:$x, :$y) }
    }

    method latch() {
        $!lock.protect: {
            for @!adds -> $ct {
                $!living{ $ct }++;
                for (-1..1) X (-1..1) -> ($dx, $dy) {
                    next if $dx == $dy == 0;
                    $!neighbors{ CT.new(:x($ct.x+$dx), :y($ct.y+$dy)) }++;
                }
            }
            @!adds = ();

            for @!removes -> $ct {
                $!living{ $ct }--;
                for (-1..1) X (-1..1) -> ($dx, $dy) {
                    next if $dx == $dy == 0;
                    $!neighbors{ CT.new(:x($ct.x+$dx), :y($ct.y+$dy)) }--;
                }
            }
            @!removes = ();
        }
    }

    multi method neighboring-cells(--> Seq:D) { $!neighbors.keys }
    multi method neighboring-cells(Int:D $neighbors --> Seq:D) {
        $!neighbors.pairs.grep(*.value == $neighbors).map(*.key)
    }
    multi method neighboring-cells(Range:D $neighbors --> Seq:D) {
        $!neighbors.pairs.grep({ .value ~~ $neighbors }).map(*.key)
    }
    multi method neighboring-cells(&neighbors --> Seq:D) {
        $!neighbors.pairs.grep(&neighbors).map(*.key)
    }

    multi method living-cells(--> Seq:D) {
        $!living.keys
    }

    multi method neighbors(--> Bag:D) { $!neighbors.Bag }
    multi method living(--> Set:D) { $!living.Set }
}
