defmodule Hangman.Impl.Game do
  alias Hangman.Types

  @type t :: %__MODULE__ {
    turns_left:   integer,
    game_state:   Types.state,
    letters:      list(String.t),
    letters_used: MapSet.t(String.t),
  }

  defstruct(
    turns_left:   7,
    game_state:   :initializing,
    letters:      [],
    letters_used: MapSet.new(),
  )

  ############################################

  @spec new_game() :: t
  def new_game do
    word_list = Dictionary.start
    new_game(Dictionary.random_word(word_list))
  end

  @spec new_game(String.t) :: list(String.t)
  def new_game(word) do
    %__MODULE__{
      letters: word|> String.codepoints
    }
  end

  ############################################

  # def make_move(game = %{game_state: state}, _guess) when state in [:won, :lost] do
    #   {game, tally(game)}
    # end

  @spec make_move(t, String.t) :: { t, Types.tally }
  def make_move(game, _guess) when game.game_state in [:won, :lost] do
    {game, tally(game)}
  end

  def make_move(game, guess) do
    return_with_tally(accept_guess(game, guess, MapSet.member?(game.letters_used, guess)))
  end

  ############################################

  defp accept_guess(game, _guess, _already_used = true) do
    %{ game | game_state: :already_used }
  end

  defp accept_guess(game, guess, _already_used) do
    %{ game | letters_used: MapSet.put(game.letters_used, guess)}
    |> score_guess(Enum.member?(game.letters, guess))
  end

  ############################################

  defp score_guess(game, _good_guess = true) do
    new_state = maybe_won(MapSet.subset?(MapSet.new(game.letters), game.letters_used))
    %{ game | game_state: new_state }
  end

  defp score_guess(game = %{turns_left: 1}, _bad_guess) do
    %{game | game_state: :lost}
  end

  defp score_guess(game, _bad_guess) do
    %{game | game_state: :bad_guess, turns_left: game.turns_left - 1}
  end

  ############################################

  def tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters:    reveal_guessed_letters(game),
      letters_used: game.letters_used |> MapSet.to_list |> Enum.sort
    }
  end

  defp return_with_tally(game) do
   { game, tally(game) }
  end

  defp reveal_guessed_letters(game = %{ game_state: :lost }) do
    game.letters
  end
  defp reveal_guessed_letters(game) do
    game.letters
    |> Enum.map(fn letter -> MapSet.member?(game.letters_used, letter) |> maybe_reveal(letter) end)
  end

  defp maybe_won(true), do: :won
  defp maybe_won(_),    do: :good_guess

  defp maybe_reveal(true, letter),  do: letter
  defp maybe_reveal(_,    _letter), do: "_"
end
