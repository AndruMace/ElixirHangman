defmodule Dictionary.Impl.WordList do

  def word_list() do
    # "assets/words.txt"
    Path.absname("/Users/andrumace/Development/Tutorials/hangman/dictionary/assets/words.txt")
    |> File.read!()
    |> String.split(~r/\n/, trim: true)
  end

  def random_word(word_list) do
    word_list |> Enum.random()
  end

  def get_words_of_n_length(word_list, n) do
   word_list |> Enum.filter(fn(x) -> length(String.codepoints(x)) == n end)
  end

end

# process == something internal to elixir, not any other kind of process
