defmodule Scitree.Config do
  @type t :: %__MODULE__{}

  @type learners :: :random_forest | :gradient_boosted_trees

  @options %{
    max_depth: 16,
    min_examples: 5
  }

  defstruct learner: nil,
            options: @options,
            task: :regression,
            label: "scitree",
            log_directory: ""

  @type tasks :: :undefined | :classification | :regression | :ranking | :categorical_uplift

  @doc """
  initializes a new classification setting.

  ## Examples

      iex> Scitree.Config.init()
      %Scitree.Config{
        label: "scitree",
        learner: nil,
        log_directory: "",
        options: %{max_depth: 16, min_examples: 5},
        task: :regression
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
        options: %{max_depth: 16, min_examples: 5},
        task: :regression
      }

  to change default options like max_depth, min_examples, can use the following example.

  Maximum depth of the tree. max_depth=1 means that all trees will be roots.
  If max_depth=-1, the depth of the tree is not limited.

  ## Examples

      iex> Scitree.Config.init() |> Scitree.Config.learner(:random_forest, max_depth: 1, min_examples: 10)
      %Scitree.Config{
        label: "scitree_label",
        learner: :random_forest,
        log_directory: "",
        options: %{max_depth: 1, min_examples: 10},
        task: :regression
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
