defmodule Scitree.Native do
  @on_load :load_nifs

  def load_nifs(), do: :erlang.load_nif('./c_src/scitree/scitree', 0)

  def train(_config, _path) do
    raise "NIF train/2 not loaded"
  end

  def predict(_reference, _model) do
    raise "NIF predict/2 not loaded"
  end

  def train_csv(_config, _path) do
    raise "NIF train_csv/2 not loaded"
  end

  def predict_csv(_reference, _model) do
    raise "NIF predict_csv/2 not loaded"
  end

  def save(_reference, _path) do
    raise "NIF save/2 not loaded"
  end
end
