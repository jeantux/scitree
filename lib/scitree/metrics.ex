defmodule Scitree.Metrics do
  @moduledoc """
  Metric functions.
  Metrics are used to measure the performance and compare
  the performance of any kind of classifier in
  easy-to-understand terms.
  All of the functions in this module are implemented as
  numerical functions and can be JIT or AOT compiled with
  any supported `Nx` compiler.
  """

  import Scholar
  import Nx.Defn

  # Standard Metrics

  @doc ~S"""
  Computes the accuracy of the given predictions.
  If the size of the last axis is 1, it performs a binary
  accuracy computation with a threshold of 0.5. Otherwise,
  computes categorical accuracy.
  ## Argument Shapes
    * `y_true` - $\(d_0, d_1, ..., d_n\)$
    * `y_pred` - $\(d_0, d_1, ..., d_n\)$
  ## Examples
      iex> Scitree.Metrics.accuracy(Nx.tensor([[0, 1], [1, 0], [1, 0]]), Nx.tensor([[0, 1], [1, 0], [0, 1]]))
      #Nx.Tensor<
        f32
        0.6666666865348816
      >
  """
  defn accuracy(y_true, y_pred) do
    Scholar.Metrics.accuracy(y_true, y_pred)
  end

  # defndelegate mean_squared_error(y_true, y_pred), to: Scitree.Losses
  # defndelegate mean_absolute_error(y_true, y_pred), to: Scitree.Losses

  @doc ~S"""
  Computes the precision of the given predictions with
  respect to the given targets.
  ## Argument Shapes
    * `y_true` - $\(d_0, d_1, ..., d_n\)$
    * `y_pred` - $\(d_0, d_1, ..., d_n\)$
  ## Options
    * `:threshold` - threshold for truth value of the predictions.
      Defaults to `0.5`
  ## Examples
      iex> Scitree.Metrics.precision(Nx.tensor([0, 1, 1, 1]), Nx.tensor([1, 0, 1, 1]))
      #Nx.Tensor<
        f32
        0.6666666865348816
      >
  """
  defn precision(y_true, y_pred, opts \\ []) do
    Scholar.Metrics.precision(y_true, y_pred, opts)
  end

  @doc ~S"""
  Computes the recall of the given predictions with
  respect to the given targets.
  ## Argument Shapes
    * `y_true` - $\(d_0, d_1, ..., d_n\)$
    * `y_pred` - $\(d_0, d_1, ..., d_n\)$
  ## Options
    * `:threshold` - threshold for truth value of the predictions.
      Defaults to `0.5`
  ## Examples
      iex> Scitree.Metrics.recall(Nx.tensor([0, 1, 1, 1]), Nx.tensor([1, 0, 1, 1]))
      #Nx.Tensor<
        f32
        0.6666666865348816
      >
  """
  defn recall(y_true, y_pred, opts \\ []) do
    Scholar.Metrics.recall(y_true, y_pred, opts)
  end

  @doc """
  Computes the number of true positive predictions with respect
  to given targets.
  ## Options
    * `:threshold` - threshold for truth value of predictions.
      Defaults to `0.5`.
  ## Examples
      iex> y_true = Nx.tensor([1, 0, 1, 1, 0, 1, 0])
      iex> y_pred = Nx.tensor([0.8, 0.6, 0.4, 0.2, 0.8, 0.2, 0.2])
      iex> Scitree.Metrics.true_positives(y_true, y_pred)
      #Nx.Tensor<
        u64
        1
      >
  """
  defn true_positives(y_true, y_pred, opts \\ []) do
    Scholar.Metrics.true_positives(y_true, y_pred, opts)
  end

  @doc """
  Computes the number of false negative predictions with respect
  to given targets.
  ## Options
    * `:threshold` - threshold for truth value of predictions.
      Defaults to `0.5`.
  ## Examples
      iex> y_true = Nx.tensor([1, 0, 1, 1, 0, 1, 0])
      iex> y_pred = Nx.tensor([0.8, 0.6, 0.4, 0.2, 0.8, 0.2, 0.2])
      iex> Scitree.Metrics.false_negatives(y_true, y_pred)
      #Nx.Tensor<
        u64
        3
      >
  """
  defn false_negatives(y_true, y_pred, opts \\ []) do
    Scholar.Metrics.false_negatives(y_true, y_pred, opts)
  end

  @doc """
  Computes the number of true negative predictions with respect
  to given targets.
  ## Options
    * `:threshold` - threshold for truth value of predictions.
      Defaults to `0.5`.
  ## Examples
      iex> y_true = Nx.tensor([1, 0, 1, 1, 0, 1, 0])
      iex> y_pred = Nx.tensor([0.8, 0.6, 0.4, 0.2, 0.8, 0.2, 0.2])
      iex> Scitree.Metrics.true_negatives(y_true, y_pred)
      #Nx.Tensor<
        u64
        1
      >
  """
  defn true_negatives(y_true, y_pred, opts \\ []) do
    Scholar.Metrics.true_negatives(y_true, y_pred, opts)
  end

  @doc """
  Computes the number of false positive predictions with respect
  to given targets.
  ## Options
    * `:threshold` - threshold for truth value of predictions.
      Defaults to `0.5`.
  ## Examples
      iex> y_true = Nx.tensor([1, 0, 1, 1, 0, 1, 0])
      iex> y_pred = Nx.tensor([0.8, 0.6, 0.4, 0.2, 0.8, 0.2, 0.2])
      iex> Scitree.Metrics.false_positives(y_true, y_pred)
      #Nx.Tensor<
        u64
        2
      >
  """
  defn false_positives(y_true, y_pred, opts \\ []) do
    Scholar.Metrics.false_positives(y_true, y_pred, opts)
  end

  @doc ~S"""
  Computes the sensitivity of the given predictions
  with respect to the given targets.
  ## Argument Shapes
    * `y_true` - $\(d_0, d_1, ..., d_n\)$
    * `y_pred` - $\(d_0, d_1, ..., d_n\)$
  ## Options
    * `:threshold` - threshold for truth value of the predictions.
      Defaults to `0.5`
  ## Examples
      iex> Scitree.Metrics.sensitivity(Nx.tensor([0, 1, 1, 1]), Nx.tensor([1, 0, 1, 1]))
      #Nx.Tensor<
        f32
        0.6666666865348816
      >
  """
  defn sensitivity(y_true, y_pred, opts \\ []) do
    Scholar.Metrics.sensitivity(y_true, y_pred, opts)
  end

  @doc ~S"""
  Computes the specificity of the given predictions
  with respect to the given targets.
  ## Argument Shapes
    * `y_true` - $\(d_0, d_1, ..., d_n\)$
    * `y_pred` - $\(d_0, d_1, ..., d_n\)$
  ## Options
    * `:threshold` - threshold for truth value of the predictions.
      Defaults to `0.5`
  ## Examples
      iex> Scitree.Metrics.specificity(Nx.tensor([0, 1, 1, 1]), Nx.tensor([1, 0, 1, 1]))
      #Nx.Tensor<
        f32
        0.0
      >
  """
  defn specificity(y_true, y_pred, opts \\ []) do
    Scholar.Metrics.specificity(y_true, y_pred, opts)
  end

  @doc ~S"""
  Calculates the mean absolute error of predictions
  with respect to targets.
  $$l_i = \sum_i |\hat{y_i} - y_i|$$
  ## Argument Shapes
    * `y_true` - $\(d_0, d_1, ..., d_n\)$
    * `y_pred` - $\(d_0, d_1, ..., d_n\)$
  ## Examples
      iex> y_true = Nx.tensor([[0.0, 1.0], [0.0, 0.0]], type: {:f, 32})
      iex> y_pred = Nx.tensor([[1.0, 1.0], [1.0, 0.0]], type: {:f, 32})
      iex> Scitree.Metrics.mean_absolute_error(y_true, y_pred)
      #Nx.Tensor<
        f32
        0.5
      >
  """
  defn mean_absolute_error(y_true, y_pred) do
    Scholar.Metrics.mean_absolute_error(y_true, y_pred)
  end

  # Combinators

  @doc """
  Returns a function which computes a running average given current average,
  new observation, and current iteration.
  ## Examples
      iex> cur_avg = 0.5
      iex> iteration = 1
      iex> y_true = Nx.tensor([[0, 1], [1, 0], [1, 0]])
      iex> y_pred = Nx.tensor([[0, 1], [1, 0], [1, 0]])
      iex> avg_acc = Scitree.Metrics.running_average(&Scitree.Metrics.accuracy/2)
      iex> avg_acc.(cur_avg, [y_true, y_pred], iteration)
      #Nx.Tensor<
        f32
        0.75
      >
  """
  def running_average(metric) do
    Scholar.Metrics.running_average(metric)
  end

  @doc """
  Returns a function which computes a running sum given current sum,
  new observation, and current iteration.
  ## Examples
      iex> cur_sum = 12
      iex> iteration = 2
      iex> y_true = Nx.tensor([0, 1, 0, 1])
      iex> y_pred = Nx.tensor([1, 1, 0, 1])
      iex> fps = Scitree.Metrics.running_sum(&Scitree.Metrics.false_positives/2)
      iex> fps.(cur_sum, [y_true, y_pred], iteration)
      #Nx.Tensor<
        s64
        13
      >
  """
  def running_sum(metric) do
    Scholar.Metrics.running_sum(metric)
  end
end
