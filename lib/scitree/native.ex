defmodule Scitree.Native do
  @moduledoc false

  @on_load :load_nifs

  def load_nifs() do
    path = :filename.join(:code.priv_dir(:scitree), 'scitree')
    :erlang.load_nif(path, 0)
  end

  def train(_config, _path), do: :erlang.nif_error(:undef)

  def predict(_reference, _model), do: :erlang.nif_error(:undef)

  def save(_reference, _path), do: :erlang.nif_error(:undef)

  def show_dataspec(_reference), do: :erlang.nif_error(:undef)
end
