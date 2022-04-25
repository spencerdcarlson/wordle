defmodule Wordle.Game do
  @moduledoc """
  Service to create and manage games.
  """

  require Logger
  alias Wordle.Game.{Mapper, State, Store}
  alias Wordle.Picker

  def create(guess) do
    # TODO choose the secret word of the day
    new_game =
      Picker.word()
      |> State.new()
      |> State.attempt(guess)
      |> Store.save()

    case new_game do
      {:ok, game = %State{}} ->
        {:ok, Mapper.call(game)}

      error ->
        Logger.error("Error creating a new game. #{inspect(error)}")
        {:error, :game_save}
    end
  end

  def guess(uuid, guess, opts \\ []) do
    with {:ok, game = %State{}} <- Store.get(uuid),
         {:ok, updated = %State{}} <- State.attempt(game, guess) |> Store.save() do
      {:ok, Mapper.call(updated, opts)}
    end
  end
end
