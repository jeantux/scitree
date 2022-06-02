defmodule Scitree.Validations do
  @moduledoc """
  Validations to ensure data is consistent and in the
  format expected by Yggdrasil.
  """

  alias Scitree.Config

  @type data :: {{String.t(), atom(), [term()]}}
  @spec validate(data, Config.t(), list()) ::
          :ok
          | {:error, atom}
          | {:error, {:incompatible_column_for_task, col_type :: atom(), valid_types :: [atom()]}}
          | {:error, {:unsupported_validation, name :: atom()}}
  def validate(data, config \\ %Config{}, validations) do
    Enum.find_value(validations, :ok, fn validation ->
      with {:ok, validator} <- get_validator(validation),
           :ok <- validator.(data, config) do
        false
      else
        error -> error
      end
    end)
  end

  defp get_validator(:label), do: {:ok, &validate_label/2}
  defp get_validator(:dataset_size), do: {:ok, &validate_dataset_size/2}
  defp get_validator(:learner), do: {:ok, &validate_config_learner/2}
  defp get_validator(:task), do: {:ok, &validate_task/2}
  defp get_validator(name), do: {:error, {:unsupported_validation, name}}

  @doc """
  Checks if the configuration label is in the dataset.

  ## Examples

      iex> Scitree.Validations.validate_label(data, config)
      {:error, :unidentified_label}
  """

  @spec validate_label(data, Config.t()) :: :ok | {:error, :unidentified_label}
  def validate_label(data, %Config{label: label}) do
    data
    |> Enum.any?(fn {title, _type, _value} -> title == label end)
    |> if do
      :ok
    else
      {:error, :unidentified_label}
    end
  end

  @doc """
  Checks if all columns are the same size.

  ## Examples

      iex> Scitree.Validations.validate_dataset_size(data, config)
      {:error, :incompatible_column_sizes}
  """
  @spec validate_dataset_size(data, Config.t()) :: :ok | {:error, :incompatible_column_sizes}
  def validate_dataset_size(data, _config) do
    {_title, _type, first} = Enum.at(data, 0)
    size = Enum.count(first)

    data
    |> Enum.all?(fn {_title, _type, vals} -> Enum.count(vals) == size end)
    |> if do
      :ok
    else
      {:error, :incompatible_column_sizes}
    end
  end

  @doc """
  Checks if config learner is valid.

  ## Examples

      iex> Scitree.Validations.validate_config_learner(data, config)
      {:error, :unknown_learner}
  """
  @spec validate_config_learner(data, Config.t()) :: :ok | {:error, :unknown_learner}
  def validate_config_learner(_data, config) do
    if config.learner in [:cart, :gradient_boosted_trees, :random_forest] do
      :ok
    else
      {:error, :unknown_learner}
    end
  end

  @doc """
  Check if the task config is compatible with the type of the
  dataset's label column.

  ## Examples

      iex> Scitree.Validations.validate_task({{"my column", :numerical, 1}}, %{label: "my column", task: :classification})
      {:error, {:incompatible_column_for_task, :numerical, [:categorical, :string]}
  """
  @spec validate_task(data, Config.t()) ::
          :ok | {:error, {:incompatible_column_for_task, atom(), [atom()]}}
  def validate_task(data, config) do
    col_type =
      data
      |> Enum.find_value(fn {title, type, _value} ->
        if title == config.label do
          type
        end
      end)

    valid_types = validate_task_types_for_config(config.task)

    if col_type in valid_types do
      :ok
    else
      {:error, {:incompatible_column_for_task, col_type, valid_types}}
    end
  end

  defp validate_task_types_for_config(:classification), do: [:categorical, :string]
  defp validate_task_types_for_config(:regression), do: [:numerical]
  defp validate_task_types_for_config(:ranking), do: [:numerical]
  defp validate_task_types_for_config(:categorical_uplift), do: [:categorical]
  defp validate_task_types_for_config(_), do: []
end
