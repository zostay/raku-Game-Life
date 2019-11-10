class Game::Life
----------------

This class is a work in progress. This class performs the work of updating a board for each turn in Conway's Game of Life.

### has Str $.start-state

This is a string representing the initial state to load into Conway's Game of Life. Every line of the string represents a line of the initial board. Each space a dead cell and each non-space a life cell.

### method next-turn-for

```perl6
method next-turn-for(
    $l,
    $t,
    $r,
    $b
) returns Mu
```

Evaluate the current board and make updates to the next. The next board is a clone of the current board, so we just make changes. The C<$l>, C<$t>, C<$r>, C<$b> items are the top-left and botto-rigth corner coordinates of the grid to work on. This modifies the C<$.next> board in place so there's no return value.

### method next-turn

```perl6
method next-turn() returns Mu
```

Sequentially generate the board state from the previous state.

### method parallel-next-turn-for

```perl6
method parallel-next-turn-for(
    $l,
    $t,
    $r,
    $b
) returns Mu
```

Determine if the board is large and break it up into separate tasks. This will then perform the actual work for each section of the board using the C<method next-turn-for> method.

### method parallel-next-turn

```perl6
method parallel-next-turn() returns Mu
```

Generate the next board from the previous state, but employ parallel computing methods to speed things up.

### method board

```perl6
method board() returns Mu
```

Return the current board. This board will always be immutable.

