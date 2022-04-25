defmodule Wordle.Game.Attempt do
  @moduledoc """
  State of an Wordle Game Attempt. This includes:
    * The secret word
    * A guess - a list of graphemes as `:correct`, `:present`, or `:absent`
  """

  defstruct word: nil, guess: nil

  def new(word), do: %__MODULE__{word: word}

  def attempt(attempt = %__MODULE__{word: word}, guess) do
    accumulator = %{result: [], letters: String.graphemes(word)}

    %{result: result} =
      guess
      |> String.graphemes()
      |> Stream.with_index()
      |> Enum.reduce(accumulator, fn {c, i}, acc = %{result: result, letters: letters} ->
        # TODO could clean this up with a struct and or private functions
        cond do
          String.at(word, i) == c ->
            %{acc | result: [{c, :correct} | result]}

          c in letters ->
            # Account for plurality
            # e.g. Guess is "atoll" and the word is "close"
            # the first "l" in "atoll" is present, but the second "l" is not
            %{acc | letters: List.delete(letters, c), result: [{c, :present} | result]}

          true ->
            %{acc | result: [{c, :absent} | result]}
        end
      end)

    %__MODULE__{attempt | guess: result}
  end

  def guess(%__MODULE__{guess: guess}), do: guess
  def guess(_), do: nil
end
