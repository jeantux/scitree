defmodule Scitree.Config do
  @type t :: %__MODULE__{}

  @type learners :: :random_forest | :gradient_boosted_trees

  @options %{
    maximum_model_size_in_memory_in_bytes: -1.0,
    maximum_training_duration_seconds: -1.0,
    random_seed: 123_456
  }

  defstruct learner: :random_forest,
            options: @options,
            task: :classification,
            label: "scitree",
            log_directory: ""

  @type tasks :: :undefined | :classification | :regression | :ranking | :categorical_uplift

  @doc """
  initializes a new classification setting.

  ## Examples

      iex> Scitree.Config.init()
      %Scitree.Config{
        label: "scitree",
        learner: :random_forest,
        log_directory: "",
        options: %{
          maximum_model_size_in_memory_in_bytes: -1.0,
          maximum_training_duration_seconds: -1.0,
          random_seed: 123456
        },
        task: :classification
      }
  """

  def init(), do: %__MODULE__{}

  @doc """
  This function defines which sorting method will be used and its options.

  If you want to use the classic Random Forest model, you can use the following example as a basis.

  ## Examples

      iex> Scitree.Config.init() |> Scitree.Config.learner(:random_forest)
      %Scitree.Config{
        label: "scitree",
        learner: :random_forest,
        log_directory: "",
        options: %{
          maximum_model_size_in_memory_in_bytes: -1.0,
          maximum_training_duration_seconds: -1.0,
          random_seed: 123456
        },
        task: :classification
      }


    Learner parameters can be changed, you can use the following options:
    (parameters that are not manually set will assume default values)

    * maximum_model_size_in_memory_in_bytes: Limit the size of the model when stored in ram.
    * maximum_training_duration_seconds: Maximum training duration of the model expressed in seconds.
    * random_seed: Random seed for the training of the model.

    To change default options, can use the following example.

  ## Examples

      iex> Scitree.Config.init() |> Scitree.Config.learner(:random_forest, random_seed: 654321)
      %Scitree.Config{
        label: "scitree",
        learner: :random_forest,
        log_directory: "",
        options: %{
          maximum_model_size_in_memory_in_bytes: -1.0,
          maximum_training_duration_seconds: -1.0,
          random_seed: 654321
        },
        task: :classification
      }
  """
  @spec learner(t(), learners(), list()) :: t()
  def learner(config, learner, opts \\ []) do
    options = Enum.into(opts, @options)

    config
    |> Map.put(:options, options)
    |> Map.put(:learner, learner)
  end

  @spec task(t(), tasks()) :: t()
  def task(config, type), do: Map.put(config, :task, type)

  @spec label(t(), String.t()) :: t()
  def label(config, label), do: Map.put(config, :label, label)

  @spec log_directory(t(), String.t()) :: t()
  def log_directory(config, dir), do: Map.put(config, :log_directory, dir)
end
