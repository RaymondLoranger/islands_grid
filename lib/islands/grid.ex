# ┌───────────────────────────────────────────────────────────────────────┐
# │ Inspired by the book "Functional Web Development" by Lance Halvorsen. │
# └───────────────────────────────────────────────────────────────────────┘
defmodule Islands.Grid do
  @moduledoc """
  A grid (map of maps) and functions for the _Game of Islands_.

  ##### Inspired by the book [Functional Web Development](https://pragprog.com/titles/lhelph/functional-web-development-with-elixir-otp-and-phoenix/) by Lance Halvorsen.
  """

  import Enum, only: [reduce: 3]

  alias Islands.{Board, Coord, Guesses, Island}

  @col_range 1..10
  @row_range 1..10

  @typedoc "A grid (map of maps) allowing the `grid[row][col]` syntax"
  @type t :: %{Coord.row() => %{Coord.col() => atom}}
  @typedoc "Function creating a tile from a cell value"
  @type tile_fun :: (atom -> IO.chardata())

  @doc """
  Creates an "empty" grid.

  ## Examples

      iex> alias Islands.Grid
      iex> grid = Grid.new()
      iex> {grid[1][1], grid[10][10]}
      {nil, nil}

      iex> alias Islands.Grid
      iex> grid = Grid.new()
      iex> for row <- 1..10 do
      iex>   for col <- 1..10, uniq: true do
      iex>     grid[row][col]
      iex>   end
      iex> end
      [[nil], [nil], [nil], [nil], [nil], [nil], [nil], [nil], [nil], [nil]]

      iex> Islands.Grid.new()
      %{
        1 => %{ 1 => nil, 2 => nil, 3 => nil, 4 => nil,  5 => nil,
                6 => nil, 7 => nil, 8 => nil, 9 => nil, 10 => nil},
        2 => %{ 1 => nil, 2 => nil, 3 => nil, 4 => nil,  5 => nil,
                6 => nil, 7 => nil, 8 => nil, 9 => nil, 10 => nil},
        3 => %{ 1 => nil, 2 => nil, 3 => nil, 4 => nil,  5 => nil,
                6 => nil, 7 => nil, 8 => nil, 9 => nil, 10 => nil},
        4 => %{ 1 => nil, 2 => nil, 3 => nil, 4 => nil,  5 => nil,
                6 => nil, 7 => nil, 8 => nil, 9 => nil, 10 => nil},
        5 => %{ 1 => nil, 2 => nil, 3 => nil, 4 => nil,  5 => nil,
                6 => nil, 7 => nil, 8 => nil, 9 => nil, 10 => nil},
        6 => %{ 1 => nil, 2 => nil, 3 => nil, 4 => nil,  5 => nil,
                6 => nil, 7 => nil, 8 => nil, 9 => nil, 10 => nil},
        7 => %{ 1 => nil, 2 => nil, 3 => nil, 4 => nil,  5 => nil,
                6 => nil, 7 => nil, 8 => nil, 9 => nil, 10 => nil},
        8 => %{ 1 => nil, 2 => nil, 3 => nil, 4 => nil,  5 => nil,
                6 => nil, 7 => nil, 8 => nil, 9 => nil, 10 => nil},
        9 => %{ 1 => nil, 2 => nil, 3 => nil, 4 => nil,  5 => nil,
                6 => nil, 7 => nil, 8 => nil, 9 => nil, 10 => nil},
        10 => %{1 => nil, 2 => nil, 3 => nil, 4 => nil,  5 => nil,
                6 => nil, 7 => nil, 8 => nil, 9 => nil, 10 => nil}
      }
  """
  @spec new :: t
  def new do
    row_map = for col <- @col_range, into: %{}, do: {col, nil}
    for row <- @row_range, into: %{}, do: {row, row_map}
  end

  @doc """
  Converts a board or guesses struct into a grid.

  ## Examples

      iex> alias Islands.{Board, Coord, Grid, Island}
      iex> {:ok, atoll_origin} = Coord.new(1, 1)
      iex> {:ok, atoll_hit} = Coord.new(1, 2)
      iex> {:ok, atoll} = Island.new(:atoll, atoll_origin)
      iex> board = Board.new() |> Board.position_island(atoll)
      iex> {:hit, :none, :no_win, board} = Board.guess(board, atoll_hit)
      iex> grid = Grid.new(board)
      iex> row_1 = {grid[1][1], grid[1][2], grid[1][3]}
      iex> row_2 = {grid[2][1], grid[2][2], grid[2][3]}
      iex> row_3 = {grid[3][1], grid[3][2], grid[3][3]}
      iex> {row_1, row_2, row_3}
      {{:atoll, :atoll_hit, nil}, {nil, :atoll, nil}, {:atoll, :atoll, nil}}
  """
  @spec new(Board.t() | Guesses.t()) :: t
  def new(board_or_guesses)

  def new(%Board{islands: islands, misses: misses}) do
    islands
    |> Map.values()
    |> reduce(new(), fn %Island{type: type, coords: coords, hits: hits}, grid ->
      grid
      |> update(coords, type)
      |> update(hits, :"#{type}_hit")
    end)
    |> update(misses, :board_miss)
  end

  def new(%Guesses{hits: hits, misses: misses}),
    do: new() |> update(hits, :hit) |> update(misses, :miss)

  @doc """
  Converts a board or guesses struct into a grid and then into a list of maps.

  Function `tile_fun` should convert each grid cell value into a colored tile
  (with embedded ANSI escape sequences). The default for `tile_fun` is function
  `Islands.Grid.Tile.new/1`.

  ## Examples

      iex> alias Islands.{Board, Coord, Grid, Island}
      iex> {:ok, atoll_origin} = Coord.new(1, 1)
      iex> {:ok, atoll_hit} = Coord.new(1, 2)
      iex> {:ok, atoll} = Island.new(:atoll, atoll_origin)
      iex> board = Board.new() |> Board.position_island(atoll)
      iex> {:hit, :none, :no_win, board} = Board.guess(board, atoll_hit)
      iex> [row_1 | _other_9_maps] = Grid.to_maps(board, & &1)
      iex> Map.take(row_1, ["row", 1, 2, 3, 10])
      %{"row" => 1, 1 => :atoll, 2 => :atoll_hit, 3 => nil, 10 => nil}
  """
  @spec to_maps(Board.t() | Guesses.t(), tile_fun) :: [map]
  def to_maps(board_or_guesses, tile_fun \\ &Islands.Grid.Tile.new/1)

  def to_maps(%Board{} = board, tile_fun) when is_function(tile_fun, 1),
    do: new(board) |> do_to_maps(tile_fun)

  def to_maps(%Guesses{} = guesses, tile_fun) when is_function(tile_fun, 1),
    do: new(guesses) |> do_to_maps(tile_fun)

  ## Private functions

  @spec update(t, Island.coords(), atom) :: t
  defp update(grid, coords, value) do
    coords
    |> MapSet.to_list()
    |> reduce(grid, fn %Coord{row: row, col: col}, grid ->
      put_in(grid[row][col], value)
    end)
  end

  @spec do_to_maps(t, tile_fun) :: [map]
  defp do_to_maps(grid, tile_fun) do
    for {row, row_map} <- grid do
      row_list = for {col, cell_val} <- row_map, do: {col, tile_fun.(cell_val)}
      [{"row", row} | row_list] |> Map.new()
    end
  end
end
