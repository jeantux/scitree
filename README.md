# Scitree

**Scitree** is a collection of **decision forest** model algorithms.<br/>
Basically this is a wrapper around the [**Yggdrasil**](https://github.com/google/yggdrasil-decision-forests) Decision Forests C ++ libraries.


## Examples

```elixir
dataset_train = # Dataset
dataset_predict = # Dataset

Scitree.Config.init()
|> Scitree.Config.label("class")
|> Scitree.Config.learner(:random_forest)
|> Scitree.Config.task(:classification)
|> Scitree.train(dataset_train)
|> Scitree.predict(dataset_predict)
```

[more examples](/examples/)
## Dependencies

* [Python3](https://www.python.org/downloads/) (Tested with version 3.8.10)
* [NumPy](https://numpy.org/) installed for compiling Tensorflow
* [Bazel](https://bazel.build/) v3.7.2 for compiling Yggdrasil and all its dependencies
* GCC >= 9.3.0
* build-essential (base-devel)

## Getting started

In order to use `Scitree`, you will need Elixir installed. Then create an Elixir project via the mix build tool:

```
$ mix new my_app
```

Then you can add `Scitree` as dependency in your `mix.exs`. At the moment you will have to use a Git dependency while we work on our first release:

```elixir
def deps do
  [
    {:scitree, "~> 0.1.0", github: "jeantux/scitree", branch: "main"}
  ]
end
```

Alternatively, inside a script or Livebook:

```elixir
Mix.install([{:scitree, "~> 0.1.0", github: "jeantux/scitree", branch: "main"}])
```
