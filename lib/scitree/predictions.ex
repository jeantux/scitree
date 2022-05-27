defmodule Scitree.Predictions do
  @doc """
  Convert probabilities to predicted class.
  This function will return the index of the class it is likely to be.

  The zero value in Yggdrasil is reserved for values outside the dictionary.

  ## Examples
    iex> pred = Nx.tensor([[0.01, 0.98, 0.1], [0.00, 0.01, 0.99]])
    iex> Scitree.Predictions.probabilities_to_class(pred)
    #Nx.Tensor<
      s64[2]
      [2, 3]
    >
  """
  def probabilities_to_class(tensor) do
    tensor
    |> Nx.argmax(axis: 1)
    |> Nx.add(1)
  end

end
