defmodule Islands.Grid.Tile do
  @moduledoc """
  Creates a tile from a cell value.
  """

  alias IO.ANSI.Plus, as: ANSI

  @doc """
  Creates a tile (ANSI codes) from `cell_value`.

  ## Examples

      iex> alias Islands.Grid.Tile
      iex> Tile.new(:atoll) # => A sandy brown tile
      [[[[[] | "\e[38;5;215m"] | "\e[48;5;215m"], "<a>"] | "\e[0m"]

      iex> alias Islands.Grid.Tile
      iex> Tile.new(:atoll_hit) # => An islamic green tile
      [[[[[] | "\e[38;5;34m"] | "\e[48;5;34m"], ">a<"] | "\e[0m"]
  """
  @spec new(atom) :: ANSI.ansidata()
  def new(cell_value)
  def new(:atoll), do: format(:sandy_brown, "<a>")
  def new(:dot), do: format(:teak, "<d>")
  def new(:l_shape), do: format(:tenne, "<l>")
  def new(:s_shape), do: format(:khaki, "<s>")
  def new(:square), do: format(:chocolate, "<q>")
  def new(:atoll_hit), do: format(:islamic_green, ">a<")
  def new(:dot_hit), do: format(:spring_green, ">d<")
  def new(:l_shape_hit), do: format(:dark_green, ">l<")
  def new(:s_shape_hit), do: format(:pale_green, ">s<")
  def new(:square_hit), do: format(:lawn_green, ">q<")
  def new(:hit), do: format(:islamic_green, ">h<")
  def new(:miss), do: format(:blue_ribbon, "<m>")
  # def new(:board_miss), do: format(:dodger_blue, "<m>")
  def new(:board_miss), do: format(:blue_ribbon, "<m>")
  def new(nil), do: format(:deep_sky_blue, "<o>")

  ## Private functions

  @spec format(atom, String.t()) :: ANSI.ansidata()
  defp format(tile_color, value) do
    # Background color same as foreground color making `value` invisible...
    ANSI.format([tile_color, :"#{tile_color}_background", value], _emit? = true)
  end
end
