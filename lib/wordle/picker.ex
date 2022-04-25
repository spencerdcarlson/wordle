defmodule Wordle.Picker do
  @moduledoc """
  Daily word picker.
  """

  require Logger

  @words :code.priv_dir(:wordle)
         |> Path.join("words.txt")
         |> File.stream!()
         |> Stream.map(&String.trim/1)
         |> Enum.into([])

  @count length(@words)

  # TODO: if we have client IDs
  # We could use "CLIENT_ID-DATE" |> hash to make every client have a different word

  @index Date.utc_today()
         |> Date.to_string()
         |> :erlang.crc32()
         |> rem(@count)

  @word Enum.at(@words, @index)

  def word, do: @word
end
