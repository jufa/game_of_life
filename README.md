### Conway's Game of Life for terminal
Ruby game of Life using fun terminal display.

#### Termianl use
`ruby game_of_life.rb`

#### Class use
```ruby
TerminalConway.new(params)

width: integer
height: integer
fill_ratio: float 0..1 initial fraction of spaces populated by live cells
rate: seconds between generations
patterns: 2D array of string filled with empty space or * to initialize cell pattern
```
