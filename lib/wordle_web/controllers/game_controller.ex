defmodule WordleWeb.GameController do
  use WordleWeb, :controller

  alias Wordle.Game

  def create(conn, %{"guess" => guess}) do
    case Game.create(guess) do
      {:ok, result} -> json(conn, result)
      _ -> json(conn, :error)
    end
  end

  def update(conn, params = %{"id" => uuid, "guess" => guess}) do
    history? = params |> Map.get("history", "false") |> String.to_existing_atom()
    history? = if is_boolean(history?), do: history?, else: false

    case Game.guess(uuid, guess, history: history?) do
      {:ok, result} -> json(conn, result)
      _ -> json(conn, :error)
    end
  end
end
