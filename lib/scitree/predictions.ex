defmodule Scitree.Predictions do
  import Nx.Defn

  @doc """
  Convert probabilities to predicted class.
  This function will return the index of the class it is likely to be.

  The zero value in yggdrasil is reserved for values outside the dictionary.

  ## Examples
    iex> pred = Nx.tensor([[0.01, 0.98, 0.1], [0.00, 0.01, 0.99]])
    iex> Scitree.Predictions.probabilities_to_class(pred)
    #Nx.Tensor<
      s64[2]
      [2, 3]
    >
  """
  def probabilities_to_class(tensor) do
    {size, _} = Nx.shape(tensor)

    0..(size - 1)
    |> Enum.map(&index_max_value(tensor[&1], 1))
    |> Enum.map(&num_to_list/1)
    |> Nx.concatenate()
  end

  defnp index_max_value(tensor, fun_or_offset \\ 0) do
    {size} = Nx.shape(tensor)

    {_, index, _, _} =
      while {i = 0, max_idx = 0, max_val = 0.0, tensor}, i < size do
        cond do
          max_val >= tensor[i] -> {i + 1, max_idx, max_val, tensor}
          :otherwise -> {i + 1, i + fun_or_offset, tensor[i], tensor}
        end
      end

    index
  end

  defp num_to_list(nx_number) do
    nx_number
    |> Nx.to_binary()
    |> Nx.from_binary({:s, 64})
  end
end
