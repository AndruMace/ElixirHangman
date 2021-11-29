defmodule Processes do
  def hello(count) do
    receive do
      { :crash, reason } ->
        exit(reason)

      { :quit } ->
        IO.puts "Bye!"

      { :add, n } ->
        hello(count+n)

      msg ->
        IO.puts("Hello #{inspect msg}")
        IO.puts("##{count}")
        hello(count)
      end
  end
end
