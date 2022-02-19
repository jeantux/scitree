defmodule Scitree.Validations do
  @moduledoc """
  Validations to ensure data is consistent and in the
  format expected by yggdrasil.
  """

  @spec validate(any, list()) :: :ok | {:error, String.t()}
  def validate(data, validators) do
    do_validate(data, nil, validators, :ok)
  end

  @spec validate(any, any, list()) :: :ok | {:error, String.t()}
  def validate(data, config, validators) do
    do_validate(data, config, validators, :ok)
  end

  defp do_validate(_data, _config, [], acc), do: acc

  defp do_validate(data, config, [h | t], acc) do
    case do_validate(data, config, h) do
      :ok -> do_validate(data, config, t, acc)
      error -> error
    end
  end

  defp do_validate(data, config, validator) do
    case get_validator(validator) do
      {:error, _} = err -> err
      validate_func -> validate_func.(data, config)
    end
  end

  defp get_validator(:label), do: &validate_label/2

  defp get_validator(:dataset_size), do: &validate_dataset_size/2

  defp get_validator(:learner), do: &validate_config_learner/2

  defp get_validator(:task), do: &validate_task/2

  defp get_validator(name), do: {:error, "validate_#{name} is not support"}

  @doc """
  Checks if the configuration label is in the dataset.

  ## Examples

      iex> Scitree.Validations.validate_label(data, config)
      {:error, "label not identified"}

  """

  @spec validate_label(tuple, %{label: String.t()}) :: :ok | {:error, any}
  def validate_label(data, %{label: label}) do
    data
    |> Tuple.to_list()
    |> Enum.any?(fn {title, _type, _value} -> title == label end)
    |> get_result("label not identified")
  end

  @doc """
  Checks if all columns are the same size.

  ## Examples

      iex> Scitree.Validations.validate_dataset_size(data, config)
      {:error, "columns with different sizes"}

  """
  def validate_dataset_size(data, _config) do
    {_title, _type, first} = elem(data, 0)
    size = Enum.count(first)

    data
    |> Tuple.to_list()
    |> Enum.all?(fn {_title, _type, vals} -> Enum.count(vals) == size end)
    |> get_result("columns with different sizes")
  end

  @doc """
  Checks if config learner is valid.

  ## Examples

      iex> Scitree.Validations.validate_config_learner(data, config)
      {:error, "The learner is either non-existing or non registered"}
  """
  def validate_config_learner(_data, config) do
    [:cart, :gradient_boosted_trees, :random_forest]
    |> Enum.member?(config.learner)
    |> get_result(" The learner is either non-existing or non registered")
  end

  @doc """
  Check if the task config is compatible with the type of the
  dataset's label column.

  ## Examples

      iex> Scitree.Validations.validate_task(data, config)
      {:error, "The label column should be CATEGORICAL for a CLASSIFICATION task"}
  """
  def validate_task(data, config) do
    {_, col_type, _} =
      data
      |> Tuple.to_list()
      |> Enum.find(fn {title, _type, _value} -> title == config.label end)

    check_type_task(col_type, config.task)
  end

  defp check_type_task(col_type, :classification) do
    valid? = col_type in [:categorical, :string]
    get_result(valid?, "The label column should be CATEGORICAL for a CLASSIFICATION task")
  end

  defp check_type_task(col_type, :regression) do
    valid? = col_type == :numerical
    get_result(valid?, "The label column should be NUMERICAL for a REGRESSION task")
  end

  defp check_type_task(col_type, :ranking) do
    valid? = col_type == :numerical
    get_result(valid?, "The label column should be NUMERICAL for a RANKING task")
  end

  defp check_type_task(col_type, :categorical_uplift) do
    valid? = col_type == :categorical
    get_result(valid?, "The label column should be CATEGORICAL for an CATEGORICAL_UPLIFT task.")
  end

  @spec get_result(boolean, any) :: :ok | {:error, any}
  def get_result(true, _reason), do: :ok

  def get_result(false, reason), do: {:error, reason}
end
