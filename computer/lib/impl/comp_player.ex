defmodule Computer.Impl.CompPlayer do

  #################### START ####################

  def start() do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    epoch_state = %{
      cycles_left: 100,
      cycles_completed: 0,
      wins:   0,
    }
    simulate({ game, tally, epoch_state })
  end

  def start(epoch_state) do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    simulate({ game, tally, epoch_state })
  end

  #################### SIMULATE ####################

  def simulate({game, tally = %{ game_state: :won }, epoch_state}) do
    IO.puts("The Computer Won! Word was: #{tally.letters |> Enum.join}")
    IO.puts("#################### WON ####################")
    epoch({epoch_state, tally})
  end

  def simulate({game, tally = %{ game_state: :lost}, epoch_state}) do
    IO.puts("The Computer Lost :( - The word was #{tally.letters |> Enum.join}")
    IO.puts("#################### LOST ####################")
    epoch({epoch_state, tally})
  end

  def simulate({game, tally, epoch_state}) do
    IO.puts feedback_for(tally)
    IO.puts(current_word(tally))
    guess = get_letter(game.letters_used)
    { updated_game, updated_tally} = Hangman.make_move(game, guess)
    # :timer.sleep(100)
    simulate({ updated_game, updated_tally, epoch_state })
  end

  #################### FEEDBACK ####################

  def feedback_for(tally = %{ game_state: :initializing }) do
    IO.ANSI.format([:bright, :white, "The word is #{tally.letters |> length} letters long!"])
  end

  def feedback_for(_tally = %{ game_state: :good_guess }) do
    "The computer got it right!"
  end

  def feedback_for(_tally = %{ game_state: :bad_guess }) do
    "The computer failed :/"
  end

  def feedback_for(_tally = %{ game_state: :already_used }) do
    "Computer, you already used this letter, who wrote your AI?"
  end

  #################### CURRENT WORD ####################

  def current_word(tally) do
    [
      IO.ANSI.format([:white, "\nWord: ", tally.letters |> Enum.join(" ")]),
      IO.ANSI.format([:bright, :red, "\nTurns left: ", tally.turns_left |> to_string]),
      IO.ANSI.format([:bright, :blue, "\nLetters Used: ", tally.letters_used |> Enum.join(",")]),
    ]
  end

  #################### GET LETTER ####################

  def get_letter(letters_used) do
    Enum.map(?a..?z, fn(x) -> <<x :: utf8>> end) |> Enum.reject(fn(x) -> Enum.member?(letters_used, x) end) |> Enum.random()
    # ?a..?z |> MapSet.new() |> MapSet.difference(letters_used) |> Enum.random()
  end

  #################### EPOCHS ####################

  def epoch({epoch_state = %{cycles_left: 0}, _game}) do
    IO.puts("Epoch Complete. AI won #{epoch_state.wins}/#{epoch_state.cycles_completed}")
  end

  def epoch({epoch_state, _game = %{game_state: :won}}) when epoch_state.cycles_left > 0 do
    updated_state = %{ epoch_state | cycles_completed: epoch_state.cycles_completed + 1, cycles_left: epoch_state.cycles_left - 1, wins: epoch_state.wins + 1}
    start(updated_state)
    # epoch(updated_state)
  end

  def epoch({epoch_state, _game}) when epoch_state.cycles_left > 0 do
    updated_state = %{ epoch_state | cycles_completed: epoch_state.cycles_completed + 1, cycles_left: epoch_state.cycles_left - 1}
    start(updated_state)
    # epoch(updated_state)
  end
end
