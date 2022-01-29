defmodule Scitree do
  alias Scitree.Native

  @moduledoc """
  Bindings to Yggdrasil Decision Forests (YDF), with a
  collection of decision forest model algorithms.
  """

  @doc """
  Train a model using the scitree config and a dataset.
  if the training is successfull, this function returns
  a model reference.

  ## Examples

      iex> Scitree.Native.train(config, data)
      {:ok, #Reference<0.492951156.1600258049.14622>}

  """
  def train(config, data), do: Native.train(config, data)

  @doc """
  Apply the model to a dataset.
  The reference of the model to be executed must be received
  in the first argument and as the second argument a valid dataset.

  ## Examples

      iex> Scitree.predict(ref, data)
      {:ok,
        [
          [0.9999991655349731, 0.0, 0.0],
          [0.01666666753590107, 0.05000000447034836, 0.9333325624465942],
          [0.013333333656191826, 0.09333331137895584, 0.8933326005935669]
        ]}

  """
  def predict(reference, data) do
    case Native.predict(reference, data) do
      {:ok, results, chunk_size} ->
        {:ok, Enum.chunk_every(results, chunk_size)}

      error ->
        error
    end
  end

  @doc """
  A data specification is a list of attribute definitions that indicates
  how a dataset is semantically understood.
  The definition of an attribute contains its name, semantic type, and
  type-dependent meta-information.

  ## Examples

      iex> Scitree.predict(ref)
      Number of records: 344
      Number of columns: 8
      ...

  """
  def show_dataspec(reference) do
    case Native.show_dataspec(reference) do
      {:ok, result} ->
        result
        |> List.to_string()
        |> IO.write()

      error ->
        error
    end
  end
end
