defmodule ScitreeTest do
  use ExUnit.Case

  alias Nx

  @temp_dir System.tmp_dir!() <> "/scitree_model_dir"

  @data_train %{
    "outlook" => [1, 1, 2, 3, 3, 3, 2, 1, 1, 3, 1, 2, 2, 3],
    "temperature" => [1, 1, 1, 2, 3, 3, 3, 2, 3, 2, 2, 2, 1, 2],
    "humidity" => [1, 1, 1, 1, 2, 2, 2, 1, 2, 2, 2, 1, 2, 1],
    "wind" => [1, 2, 1, 1, 1, 2, 2, 1, 1, 1, 2, 2, 1, 2],
    "play_tennis" => [1, 1, 2, 2, 2, 1, 2, 1, 2, 2, 2, 2, 2, 1]
  }

  @data_predict %{
    "outlook" => [1, 1, 2, 3, 3],
    "temperature" => [1, 1, 1, 2, 3],
    "humidity" => [1, 1, 1, 1, 2],
    "wind" => [1, 2, 1, 1, 1]
  }

  describe "classification task" do
    test "train label not identified" do
      config = Scitree.Config.init() |> Scitree.Config.label("invalid")
      assert_raise RuntimeError, fn -> Scitree.train(config, @data_train) end
    end

    test "columns with different size" do
      config = Scitree.Config.init() |> Scitree.Config.label("play_tennis")

      dataset = %{
        "outlook" => [1, 1, 2, 3, 3, 3, 2, 1],
        "temperature" => [1, 1, 1, 2, 3, 3, 3, 2, 3, 2, 2, 2, 1, 2],
        "humidity" => [1, 1, 1, 1, 2, 2, 2, 1, 2, 2, 2, 1, 2, 1],
        "wind" => [1, 2, 1, 1, 1, 2, 2, 1, 1, 1, 2, 2, 1, 2],
        "play_tennis" => [1, 1, 2, 2, 2, 1, 2, 1, 2, 2, 2, 2, 2, 1]
      }

      assert_raise RuntimeError, fn -> Scitree.train(config, dataset) end
    end

    test "prediction with default train" do
      config = Scitree.Config.init() |> Scitree.Config.label("play_tennis")
      ref = Scitree.train(config, @data_train)

      expected =
        Nx.tensor([
          [0.09257776290178299],
          [0.007093166466802359],
          [0.90837562084198],
          [0.6750206351280212],
          [0.9997445940971375]
        ])

      result = Scitree.predict(ref, @data_predict)
      assert result == expected
    end

    test "prediction with random forest train" do
      config =
        Scitree.Config.init()
        |> Scitree.Config.label("play_tennis")
        |> Scitree.Config.learner(:random_forest)

      ref = Scitree.train(config, @data_train)

      expected =
        Nx.tensor([
          [0.37999972701072693],
          [0.2599998414516449],
          [0.6099995374679565],
          [0.5366662740707397],
          [0.21999986469745636]
        ])

      result = Scitree.predict(ref, @data_predict)
      assert result == expected
    end

    test "save and load models" do
      Scitree.Config.init()
      |> Scitree.Config.label("play_tennis")
      |> Scitree.train(@data_train)
      |> Scitree.save(@temp_dir)

      ref = Scitree.load(@temp_dir)

      expected =
        Nx.tensor([
          [0.09257776290178299],
          [0.007093166466802359],
          [0.90837562084198],
          [0.6750206351280212],
          [0.9997445940971375]
        ])

      result = Scitree.predict(ref, @data_predict)
      File.rm_rf(@temp_dir)
      assert result == expected
    end
  end
end
