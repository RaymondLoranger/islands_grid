# ┌───────────────────────────────────────────────────────────────────────┐
# │ Inspired by the book "Functional Web Development" by Lance Halvorsen. │
# └───────────────────────────────────────────────────────────────────────┘
defmodule Islands.Grid do
  @moduledoc """
  A grid (map of maps) and functions for the _Game of Islands_.

  ##### Inspired by the book [Functional Web Development](https://pragprog.com/book/lhelph/functional-web-development-with-elixir-otp-and-phoenix) by Lance Halvorsen.
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
  """
  @spec new :: t
  def new do
    row_map = for col <- @col_range, into: %{}, do: {col, nil}
    for row <- @row_range, into: %{}, do: {row, row_map}
  end

  @doc """
  Converts a board or guesses struct into a grid.
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
  Function `tile_fun` converts each grid cell value into a colored tile (with
  embedded ANSI escapes). The default for `tile_fun` is function
  `Islands.Grid.Tile.new/1`.
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
