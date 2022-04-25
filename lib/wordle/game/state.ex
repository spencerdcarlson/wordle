defmodule Wordle.Game.State do
  @moduledoc """
  State of a Wordle Game. This includes:
    * The maximum allowed attempts
    * The secret word
    * All attempts at guessing the word
    * A game UUID
  """

  alias Wordle.Game.Attempt

  defstruct max_attempts: 5, word: nil, attempts: [], uuid: nil

  def new(word), do: %__MODULE__{word: word, uuid: UUID.uuid4()}

  def uuid(%__MODULE__{uuid: uuid}), do: uuid

  def end?(%__MODULE__{max_attempts: max, attempts: attempts}) do
    length(attempts) >= max
  end

  def solved?(%__MODULE__{attempts: attempts}) do
    !(attempts |> Enum.find(&all_correct?/1) |> is_nil())
  end

  def attempts(%__MODULE__{attempts: attempts}), do: attempts

  def attempt(game = %__MODULE__{word: word, attempts: attempts}, guess) do
    if end?(game) || solved?(game) do
      # Can only attempt as < max_attempts or if game is not solved
      game
    else
      attempt =
        word
        |> Attempt.new()
        |> Attempt.attempt(guess)

      %__MODULE__{game | attempts: [attempt | attempts]}
    end
  end

  def attempt(game), do: game

  def last_attempt(%__MODULE__{attempts: attempts}), do: List.first(attempts)

  defp all_correct?(%Attempt{guess: guess}), do: Enum.all?(guess, &correct?/1)
  defp all_correct?(_), do: false

  defp correct?({_, :correct}), do: true
  defp correct?(_), do: false
end
