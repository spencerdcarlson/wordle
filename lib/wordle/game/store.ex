defmodule Wordle.Game.Store do
  @moduledoc """
  Store all `Wordle.Game.State` and allow lookup by `Wordle.Game.State.uuid`
  """

  use GenServer

  require Logger
  alias Wordle.Game.State

  @table :games
  @ets_opts [:set, :public, :named_table, write_concurrency: true, read_concurrency: true]

  def start_link(opts) do
    {gen_opts, other} =
      Keyword.split(opts, [:name, :timeout, :debug, :spawn_opt, :hibernate_after])

    gen_opts = Keyword.put_new(gen_opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, other, gen_opts)
  end

  def init(opts) do
    {ets_opts, other} = Keyword.split(opts, [:ets_opts])
    ets_opts = Keyword.get(ets_opts, :ets_opts, @ets_opts)

    table = Keyword.get(other, :table, @table)
    Logger.info("Creating #{inspect(table)} ets table with #{inspect(ets_opts)}")
    pid = :ets.new(table, ets_opts)
    {:ok, pid}
  end

  def save(table \\ @table, game)

  def save(table, game = %State{uuid: uuid}) when not is_nil(uuid) do
    if :ets.insert(table, {uuid, game}), do: {:ok, game}, else: {:error, :not_saved}
  end

  def save(_, game) do
    Logger.warn("Could not save game. #{inspect(game)}")
    {:error, :not_saved}
  end

  def get(table \\ @table, uuid) do
    {:ok, :ets.lookup_element(table, uuid, 2)}
  rescue
    _ -> {:error, :not_found}
  end
end
