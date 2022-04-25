defmodule Wordle.Game.Mapper do
  alias Wordle.Game.{Attempt, State}

  def call(game = %State{uuid: uuid}, opts \\ []) do
    history? = Keyword.get(opts, :history, false)
    result = %{id: uuid, solved: State.solved?(game)}

    mapped_attempts =
      game
      |> attempts(history?)
      |> Enum.reverse()
      |> Stream.with_index()
      |> Enum.map(&map_attempts(&1, history?))

    if history? do
      Map.put(result, :attempts, mapped_attempts)
    else
      mapped_attempts
      |> List.first()
      |> Map.merge(result)
    end
  end

  defp attempts(game = %State{}, true), do: State.attempts(game)

  defp attempts(game = %State{}, false), do: State.last_attempt(game) |> List.wrap()

  defp map_attempts({attempt = %Attempt{}, i}, true) do
    %{
      attempt: i,
      results:
        attempt
        |> Attempt.guess()
        |> Enum.reverse()
        |> Stream.with_index()
        |> Enum.map(&map_guess/1)
    }
  end

  defp map_attempts({attempt = %Attempt{}, _}, false) do
    %{
      results:
        attempt
        |> Attempt.guess()
        |> Enum.reverse()
        |> Stream.with_index()
        |> Enum.map(&map_guess/1)
    }
  end

  defp map_guess({{letter, result}, i}), do: %{letter: letter, result: result, location: i}
end
