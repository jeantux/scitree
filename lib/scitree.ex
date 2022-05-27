defmodule Scitree do
  @moduledoc """
  Bindings to Yggdrasil Decision Forests (YDF), with a
  collection of decision forest model algorithms.
  """

  alias Scitree.Native
  alias Scitree.Infer
  alias Scitree.Validations

  @train_validations [:label, :dataset_size, :learner, :task]

  @pred_validations [:dataset_size]

  @doc """
  Train a model using a `Scitree` config structure and a dataset.
  If training is successful, this function returns a model reference.

  ## Examples

      iex> Scitree.Native.train(config, data)
      #Reference<0.492951156.1600258049.14622>

  """
  def train(config, data) do
    data = Infer.execute(data)

    with :ok <- Validations.validate(data, config, @train_validations),
         {:ok, ref} <- Native.train(config, data) do
      ref
    else
      {:error, reason} ->
        raise inspect(reason)
    end
  end

  @doc """
  Apply a model to a dataset.

  The model reference to be executed must be passed
  as the first argument and a valid dataset must be
  passert as the second argument.

  ## Examples

      iex> Scitree.predict(ref, data)
      #Nx.Tensor<
        f32[3][3]
        [
          [0.2366665154695511, 0.0, 0.763332724571228],
          [0.2366665154695511, 0.0, 0.763332724571228],
          [0.0, 0.9999991655349731, 0.0]
        ]
      >
  """
  def predict(reference, data) do
    data = Infer.execute(data)

    with :ok <- Validations.validate(data, @pred_validations),
         {:ok, results, chunk_size} <- Native.predict(reference, data) do
      results
      |> Enum.chunk_every(chunk_size)
      |> Nx.tensor()
    else
      {:error, reason} ->
        raise reason
    end
  end

  @doc """
  A data specification is a list of attribute definitions that indicates
  how a dataset is semantically understood.
  The definition of an attribute contains its name, semantic type, and
  type-dependent meta-information.

  ## Examples

      iex> Scitree.show_dataspec(ref)
      Number of records: 344
      Number of columns: 8
      ...
      #Reference<0.1739393528.1989279747.143562>
  """
  def inspect_dataspec(reference) do
    case Native.show_dataspec(reference) do
      {:ok, result} ->
        IO.puts(result)

        reference

      {:error, reason} ->
        raise reason
    end
  end

  @doc """
  Save the model in a directory.

  The directory must not yet exist and will be created by
  this function.

  ## Examples

      iex> Scitree.save(ref, "/home/user/")
      #Reference<0.1739393528.1989279747.143562>
  """
  def save(ref, path) do
    if File.dir?(path) do
      raise "The directory already exists"
    else
      case Scitree.Native.save(ref, path) do
        :ok ->
          ref

        {:error, reason} ->
          raise reason
      end
    end
  end

  @doc """
  Loads a saved trained model and returns its model reference.

  ## Examples

      iex> Scitree.load("/home/user/")
      #Reference<0.1739393528.1989279747.143562>
  """
  def load(path) do
    case Scitree.Native.load(path) do
      {:ok, ref} ->
        ref

      {:error, reason} ->
        raise reason
    end
  end
end
