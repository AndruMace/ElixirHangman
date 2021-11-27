defmodule HangmanImplGameTest do
  use ExUnit.Case
  alias Hangman.Impl.Game

  test "new game returns structure" do
    game = Game.new_game
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("wombat")
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) == 6
  end

  test "return same state if game is won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("Wombat")
      game = Map.put(game, :game_state, state)
      { new_game, _tally } = Game.make_move(game, "X")
      assert new_game == game
    end
  end

  test "check :good_guess returned if letter in word" do
    game = Game.new_game("wombat")
    {_game, tally} = Game.make_move(game, "o")
    assert tally.game_state == :good_guess
    {_game, tally} = Game.make_move(game, "m")
    assert tally.game_state == :good_guess
  end

  test "check for :bad_guess" do
    game = Game.new_game("wombat")
    {_game, tally} = Game.make_move(game, "z")
    assert tally.game_state == :bad_guess

    {_game, tally} = Game.make_move(game, "w")
    assert tally.game_state == :good_guess

    {_game, tally} = Game.make_move(game, "x")
    assert tally.game_state == :bad_guess
  end

  test "can handle a sequence of moves" do
    # hello
    [
      # guess | state | turns | letter                    | used
      ["a", :bad_guess,     6,  ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used,  6,  ["_", "_", "_", "_", "_"], ["a"]],
      ["b", :bad_guess,     5,  ["_", "_", "_", "_", "_"], ["a", "b"]],
      ["c", :bad_guess,     4,  ["_", "_", "_", "_", "_"], ["a", "b", "c"]],
      ["d", :bad_guess,     3,  ["_", "_", "_", "_", "_"], ["a", "b", "c", "d"]],
      ["e", :good_guess,    3,  ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e"]],
      ["f", :bad_guess,     2,  ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f"]],
      ["g", :bad_guess,     1,  ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g"]],
      ["h", :good_guess,    1,  ["h", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g", "h"]],
      ["i", :lost,          1,  ["h", "e", "l", "l", "o"], ["a", "b", "c", "d", "e", "f", "g", "h", "i"]],
    ] |> test_sequence_of_moves()
  end

  def test_sequence_of_moves(script) do
    game = Game.new_game("hello")
    Enum.reduce(script, game, &check_one_move/2)
  end

  defp check_one_move([ guess, state, turns, letters, used ], game) do
    { game, tally } = Game.make_move(game, guess)

    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert tally.letters_used == used
    game
  end
end
