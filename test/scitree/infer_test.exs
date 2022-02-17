defmodule Scitree.InferTest do
  use ExUnit.Case
  alias Scitree.Infer

  test "Inference of dataset with basic types" do
    data = %{
      bill_depth_mm: [18.7, 15.5, 18.7],
      island: ["Dream", "Dream", "Torgersen"],
      sex: [false, false, true],
      species: ["Chinstrap", "Adelie", "Adelie"],
      year: [2009, 2009, 2007]
    }

    expected = {
      {"bill_depth_mm", :numerical, [18.7, 15.5, 18.7]},
      {"island", :string, ["Dream", "Dream", "Torgersen"]},
      {"sex", :categorical, [false, false, true]},
      {"species", :string, ["Chinstrap", "Adelie", "Adelie"]},
      {"year", :categorical, [2009, 2009, 2007]}
    }

    assert Infer.execute(data) == expected
  end
end
