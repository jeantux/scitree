defmodule Scitree.Infer do
  @doc """
  Returns a list of `{title, type, data}`-tuples.

  ## Examples
      iex> data = %{:id => [1, 2, 3], :title => ["a", "b", "c"]}
      iex> Scitree.Infer.execute(data)
      [{"id", :categorical, [1, 2, 3]},
       {"title", :string, ["a", "b", "c"]}]
  """
  def execute(data) do
    for {title, values} <- data,
        [val | _] = values do
      inferred_type = infer_column_type(val)
      {to_string(title), inferred_type, values}
    end
  end

  defp infer_column_type(val) when is_integer(val), do: :categorical
  defp infer_column_type(val) when is_boolean(val), do: :categorical
  defp infer_column_type(val) when is_float(val), do: :numerical
  defp infer_column_type(val) when is_binary(val), do: :string
  defp infer_column_type(_), do: :unknown
end
