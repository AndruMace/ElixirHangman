defmodule Computer do

  alias Computer.Impl.CompPlayer, as: Comp

  @spec start() :: :okie
  defdelegate start(), to: Comp
end
