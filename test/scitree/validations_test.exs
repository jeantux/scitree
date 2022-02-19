defmodule Scitree.ValidationsTest do
  use ExUnit.Case
  alias Scitree.Validations, as: Val
  alias Scitree.Config

  test "test validate_label/2" do
    simple_penguins_dataset = {
      {"bill_depth_mm", :numerical, [18.7, 15.5, 18.7]},
      {"island", :string, ["Dream", "Dream", "Torgersen"]},
      {"year", :categorical, [2009, 2009, 2007]}
    }

    expected = {:error, "label not identified"}
    config = Config.init() |> Config.label("species")
    result = Val.validate_label(simple_penguins_dataset, config)

    assert result == expected
  end

  test "test validate_dataset_size/2" do
    simple_penguins_dataset = {
      {"bill_depth_mm", :numerical, [18.7, 15.5, 18.7]},
      {"island", :string, ["Dream", "Dream"]}
    }

    expected = {:error, "columns with different sizes"}
    result = Val.validate_dataset_size(simple_penguins_dataset, nil)

    assert result == expected
  end

  test "test validate_config_learner/2" do
    expected = {:error, " The learner is either non-existing or non registered"}
    config = Config.init() |> Config.learner(:unknown_random)
    result = Val.validate_config_learner(nil, config)

    assert result == expected
  end

  test "test classificationtask and categorical column" do
    simple_penguins_dataset = {
      {"bill_depth_mm", :numerical, [18.7, 15.5, 18.7]},
      {"species", :categorical, [1, 2, 2]}
    }

    config =
      Config.init()
      |> Config.task(:classification)
      |> Config.label("species")

    result = Val.validate_task(simple_penguins_dataset, config)

    assert result == :ok
  end

  test "test classification task and string column" do
    simple_penguins_dataset = {
      {"bill_depth_mm", :numerical, [18.7, 15.5, 18.7]},
      {"species", :string, ["Chinstrap", "Adelie", "Adelie"]}
    }

    config =
      Config.init()
      |> Config.task(:classification)
      |> Config.label("species")

    result = Val.validate_task(simple_penguins_dataset, config)

    assert result == :ok
  end

  test "test regression task and numerical column" do
    simple_penguins_dataset = {
      {"bill_depth_mm", :numerical, [18.7, 15.5, 18.7]},
      {"species", :string, ["Chinstrap", "Adelie", "Adelie"]}
    }

    config =
      Config.init()
      |> Config.task(:regression)
      |> Config.label("bill_depth_mm")

    result = Val.validate_task(simple_penguins_dataset, config)

    assert result == :ok
  end

  test "test regression task and ranking column" do
    simple_penguins_dataset = {
      {"bill_depth_mm", :numerical, [18.7, 15.5, 18.7]},
      {"species", :string, ["Chinstrap", "Adelie", "Adelie"]}
    }

    config =
      Config.init()
      |> Config.task(:ranking)
      |> Config.label("bill_depth_mm")

    result = Val.validate_task(simple_penguins_dataset, config)

    assert result == :ok
  end

  test "test categorical_uplift task and categorical column" do
    simple_penguins_dataset = {
      {"bill_depth_mm", :numerical, [18.7, 15.5, 18.7]},
      {"species", :categorical, [1, 2, 2]}
    }

    config =
      Config.init()
      |> Config.task(:categorical_uplift)
      |> Config.label("species")

    result = Val.validate_task(simple_penguins_dataset, config)

    assert result == :ok
  end
end
