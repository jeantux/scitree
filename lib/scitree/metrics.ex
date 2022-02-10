defmodule Scitree.Metrics do
  defstruct accuracy: 0,
            cols_representation: [],
            default_accuracy: 0,
            default_error_rate: 0,
            default_loss: 0,
            error_rate: 0,
            loss: 0,
            number_predictions: 0

  def init(), do: %__MODULE__{}

  def init(metrics) do
    %__MODULE__{}
    |> Map.merge(metrics)
    |> format_dataset()
  end

  defp format_dataset(metrics) do
    metrics
    |> Map.map(fn {key, value} ->
      cond do
        key == :cols_representation -> 
          value
          |> List.delete('<OOD>')
          |> Enum.map(&List.to_string/1)

        true -> value
      end
    end)
  end
end

