defmodule Scitree.Infer do

  @doc """
  Returns a tuple with the title, type and data.

  ## Examples
      iex> data = %{:id => [1, 2, 3], :title => ["a", "b", "c"]}
      iex> Scitree.Inference.execute(data)
      {{"id", :categorical, [1, 2, 3]},
       {"title", :string, ["a", "b", "c"]}}
  """
  def execute(data) do
    data
    |> infer()
    |> normalize()
  end

  defp infer(data) do
    for {title, values} <- data,
        [val | _] = values do
      cond do
        is_number(val) -> {title, :categorical, values}
        is_boolean(val) -> {title, :categorical, values}
        is_float(val) -> {title, :numerical, values}
        is_binary(val) -> {title, :string, values}
        true -> {title, :unknown, values}
      end
    end
  end

  defp normalize(data) do
    for {title, type, values} <- data do
      str_title = if is_atom(title), do: Atom.to_string(title), else: title
      {str_title, type, values}
    end
    |> List.to_tuple()
  end
end
