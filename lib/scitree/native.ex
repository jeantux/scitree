defmodule Scitree.Native do
  @on_load :load_nifs

  def load_nifs(), do: :erlang.load_nif('./c_src/scitree/scitree', 0)

  def train(_config, _path) do
    raise "NIF train_dataset_path/2 not loaded"
  end

  def predict(_config, _model) do
    raise "NIF predict/2 not loaded"
  end
end
