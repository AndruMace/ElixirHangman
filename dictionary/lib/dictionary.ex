defmodule Dictionary do
  alias Dictionary.Runtime.Server
  @opaque t :: Server.t

  defdelegate random_word(), to: Server
end
