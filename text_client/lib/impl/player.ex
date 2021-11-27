defmodule TextClient.Impl.Player do

  @typep game :: Hangman.game
  @typep tally :: Hangman.tally
  @typep state :: { game, tally }

  #################### START ####################

  @spec start() :: :ok
  def start do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    interact({ game, tally })
  end

  #################### INTERACT ####################

  def interact({_game, _tally = %{ game_state: :won }}) do
    IO.puts "Congrats! You won!"
  end

  def interact({_game, tally = %{ game_state: :lost }}) do
    IO.puts "You lose :( - The word was #{tally.letters |> Enum.join}"
  end

  def interact({ game, tally }) do
    IO.puts feedback_for(tally)
    IO.puts current_word(tally)
    guess = get_guess()
    { updated_game, updated_tally} = Hangman.make_move(game, guess)
    interact({ updated_game, updated_tally })
  end

  #################### FEEDBACK ####################

  def feedback_for(tally = %{ game_state: :initializing }) do
    IO.ANSI.format([:bright, :white, "Welcome! The word is #{tally.letters |> length} letters long!"])
  end

  def feedback_for(_tally = %{ game_state: :good_guess }) do
    "Good one!"
  end

  def feedback_for(_tally = %{ game_state: :bad_guess }) do
    "Oops, try again"
  end

  def feedback_for(_tally = %{ game_state: :already_used }) do
    "You've already used that letter."
  end

  #################### CURRENT WORD ####################

  def current_word(tally) do
    [
      IO.ANSI.format([:white, "\nWord: ", tally.letters |> Enum.join(" ")]),
      IO.ANSI.format([:bright, :red, "\nTurns left: ", tally.turns_left |> to_string]),
      IO.ANSI.format([:bright, :blue, "\nLetters Used: ", tally.letters_used |> Enum.join(",")]),
    ]
  end

  #################### GET GUESS ####################

  def get_guess() do
    IO.gets(IO.ANSI.format([:green, "\nNext Letter: "]))
    |> String.trim()
    |> String.downcase()
  end
end
