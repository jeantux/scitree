defmodule Scitree do
  @moduledoc """
  Scitree is a collection of state-of-the-art algorithms for Decision Forest model algorithms.
  """

  alias Scitree.Native
  alias Scitree.Infer
  alias Scitree.Validations, as: Val
  alias Nx

  @train_validations [:label, :dataset_size, :learner, :task]

  @pred_validations [:dataset_size]

  @doc """
  Train a model using the scitree config and a dataset.
  if the training is successfull, this function returns
  a model reference.

  ## Examples
      iex> data_train = %{
      ...>   "outlook" => [1, 1, 2, 3, 3, 3, 2, 1, 1, 3, 1, 2, 2, 3],
      ...>   "temperature" => [1, 1, 1, 2, 3, 3, 3, 2, 3, 2, 2, 2, 1, 2],
      ...>   "humidity" => [1, 1, 1, 1, 2, 2, 2, 1, 2, 2, 2, 1, 2, 1],
      ...>   "wind" => [1, 2, 1, 1, 1, 2, 2, 1, 1, 1, 2, 2, 1, 2],
      ...>   "play_tennis" => [1, 1, 2, 2, 2, 1, 2, 1, 2, 2, 2, 2, 2, 1]
      ...> }
      iex> config = Scitree.Config.init() |> Scitree.Config.label("play_tennis")
      iex> Scitree.train(config, data_train)
  """
  def train(config, data) do
    data = Infer.execute(data)

    case Val.validate(data, config, @train_validations) do
      :ok ->
        case Native.train(config, data) do
          {:ok, ref} ->
            ref

          {:error, reason} ->
            raise List.to_string(reason)
        end

      {:error, reason} ->
        raise reason
    end
  end

  @doc """
  Apply the model to a dataset.
  The reference of the model to be executed must be received
  in the first argument and as the second argument a valid dataset.

  ## Examples
      iex> data_train = %{
      ...>   "outlook" => [1, 1, 2, 3, 3, 3, 2, 1, 1, 3, 1, 2, 2, 3],
      ...>   "temperature" => [1, 1, 1, 2, 3, 3, 3, 2, 3, 2, 2, 2, 1, 2],
      ...>   "humidity" => [1, 1, 1, 1, 2, 2, 2, 1, 2, 2, 2, 1, 2, 1],
      ...>   "wind" => [1, 2, 1, 1, 1, 2, 2, 1, 1, 1, 2, 2, 1, 2],
      ...>   "play_tennis" => [1, 1, 2, 2, 2, 1, 2, 1, 2, 2, 2, 2, 2, 1]
      ...> }
      iex> data_predict = %{
      ...>   "outlook" => [1, 1, 2, 3, 3],
      ...>   "temperature" => [1, 1, 1, 2, 3],
      ...>   "humidity" => [1, 1, 1, 1, 2],
      ...>   "wind" => [1, 2, 1, 1, 1]
      ...> }
      iex> config = Scitree.Config.init() |> Scitree.Config.label("play_tennis")
      iex> ref = Scitree.train(config, data_train)
      iex> Scitree.predict(ref, data_predict)
      #Nx.Tensor<
        f32[5][1]
        [
          [0.09257776290178299],
          [0.007093166466802359],
          [0.90837562084198],
          [0.6750206351280212],
          [0.9997445940971375]
        ]
      >
  """
  def predict(reference, data) do
    data = Infer.execute(data)

    case Val.validate(data, @pred_validations) do
      :ok ->
        case Native.predict(reference, data) do
          {:ok, results, chunk_size} ->
            results
            |> Enum.chunk_every(chunk_size)
            |> Nx.tensor()

          {:error, reason} ->
            raise List.to_string(reason)
        end

      {:error, reason} ->
        raise reason
    end
  end

  @doc """
  A data specification is a list of attribute definitions that indicates
  how a dataset is semantically understood.
  The definition of an attribute contains its name, semantic type, and
  type-dependent meta-information.

  You can configure a simple template:

      data_train = %{
        "outlook" => [1, 1, 2, 3, 3, 3, 2, 1, 1, 3, 1, 2, 2, 3],
        "temperature" => [1, 1, 1, 2, 3, 3, 3, 2, 3, 2, 2, 2, 1, 2],
        "humidity" => [1, 1, 1, 1, 2, 2, 2, 1, 2, 2, 2, 1, 2, 1],
        "wind" => [1, 2, 1, 1, 1, 2, 2, 1, 1, 1, 2, 2, 1, 2],
        "play_tennis" => [1, 1, 2, 2, 2, 1, 2, 1, 2, 2, 2, 2, 2, 1]
      }

      ref =
        Scitree.Config.init()
        |> Scitree.Config.label("play_tennis")
        |> Scitree.train(data_train)

  You can inspect the model to fetch the details:

      Number of records: 14
      Number of columns: 5

      Number of columns by type:
              CATEGORICAL: 5 (100%)

      Columns:

      CATEGORICAL: 5 (100%)
              0: "humidity" CATEGORICAL integerized vocab-size:3 no-ood-item
              1: "outlook" CATEGORICAL integerized vocab-size:4 no-ood-item
              2: "play_tennis" CATEGORICAL integerized vocab-size:3 no-ood-item
              3: "temperature" CATEGORICAL integerized vocab-size:4 no-ood-item
              4: "wind" CATEGORICAL integerized vocab-size:3 no-ood-item

      Terminology:
              nas: Number of non-available (i.e. missing) values.
              ood: Out of dictionary.
              manually-defined: Attribute which type is manually defined by the user i.e. the type was not automatically inferred.
              tokenized: The attribute value is obtained through tokenization.
              has-dict: The attribute is attached to a string dictionary e.g. a categorical attribute stored as a string.
              vocab-size: Number of unique values.
  """
  def inspect_dataspec(reference) do
    case Native.show_dataspec(reference) do
      {:ok, result} ->
        result
        |> List.to_string()
        |> IO.write()

        reference

      {:error, reason} ->
        raise List.to_string(reason)
    end
  end

  @doc """
  Save the model in a directory.

  The directory must not yet exist and will be created by
  this function.
  """
  def save(ref, path) do
    if File.dir?(path) do
      raise "The directory already exists"
    else
      case Scitree.Native.save(ref, path) do
        :ok ->
          ref

        {:error, reason} ->
          raise List.to_string(reason)
      end
    end
  end

  @doc """
  loads a saved training and returns a model reference
  based on the path.
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
