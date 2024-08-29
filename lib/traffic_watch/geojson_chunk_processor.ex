defmodule TrafficWatch.GeoJSONChunkProcessor do
  use Oban.Worker, queue: :default, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"features" => features}}) do
    features
    |> Enum.map(&transform_feature/1)
    |> Enum.map(&save_results/1)

    :ok
  end

  defp transform_feature(feature) do
    %{
      type: "LineString",
      coordinates: transform_coords(feature["geometry"]["coordinates"])
    }
  end

  defp transform_coords(nil), do: []

  defp transform_coords(coordinates) do
    Enum.map(coordinates, fn [x, y] -> TrafficWatch.CoordTransform.transform_coords(x, y) end)
  end

  defp save_results(result) do
    modified_result =
      result
      |> Map.update!(:coordinates, fn coords ->
        Enum.map(coords, fn {x, y} -> [x, y] end)
      end)

    %{data: modified_result}
    |> TrafficWatch.ConstructionProjects.create_construction_project()
  end
end
