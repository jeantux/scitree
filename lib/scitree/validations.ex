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
    |> Enum.any?(fn {title, _value, _} -> title == label end)
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

  @spec get_result(boolean, any) :: :ok | {:error, any}
  def get_result(true, _reason), do: :ok

  def get_result(false, reason), do: {:error, reason}
end
