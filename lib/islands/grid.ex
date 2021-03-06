# ┌───────────────────────────────────────────────────────────────────────┐
# │ Inspired by the book "Functional Web Development" by Lance Halvorsen. │
# └───────────────────────────────────────────────────────────────────────┘
defmodule Islands.Grid do
  @moduledoc """
  Creates a `grid` (map of maps) for the _Game of Islands_.

  Convenience module for client applications.

  Converts a `board` or `guesses` struct into a `grid` (map of maps).
  Also converts a `board` or `guesses` struct into a list of maps.

  ##### Inspired by the book [Functional Web Development](https://pragprog.com/book/lhelph/functional-web-development-with-elixir-otp-and-phoenix) by Lance Halvorsen.
  """

  import Enum, only: [reduce: 3]

  alias __MODULE__.Tile
  alias IO.ANSI.Plus, as: ANSI
  alias Islands.{Board, Coord, Guesses, Island}

  @coord_range 1..10

  @type t :: %{Coord.row() => %{Coord.col() => atom}}
  @type tile_fun :: (atom -> ANSI.ansidata())

  @doc """
  Returns an "empty" grid.
  """
  @spec new :: t
  def new do
    for row <- @coord_range, into: %{} do
      {row, for(col <- @coord_range, into: %{}, do: {col, nil})}
    end
  end

  @doc """
  Converts a `board` or `guesses` struct into a `grid` (map of maps).
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
  Converts a `board` or `guesses` struct into a list of maps.
  """
  @spec to_maps(Board.t() | Guesses.t(), tile_fun) :: [map]
  def to_maps(board_or_guesses, fun \\ &Tile.new/1)

  def to_maps(%Board{} = board, fun) when is_function(fun, 1),
    do: new(board) |> do_to_maps(fun)

  def to_maps(%Guesses{} = guesses, fun) when is_function(fun, 1),
    do: new(guesses) |> do_to_maps(fun)

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
  defp do_to_maps(%{} = grid, fun) do
    for {row_num, row_map} <- grid do
      [
        {"row", row_num}
        | for({col_num, cell_val} <- row_map, do: {col_num, fun.(cell_val)})
      ]
      |> Map.new()
    end
  end
end
