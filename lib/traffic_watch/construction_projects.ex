defmodule TrafficWatch.ConstructionProjects do
  import Ecto.Query, warn: false

  alias TrafficWatch.ConstructionProject
  alias TrafficWatch.Repo

  def get_construction_projects, do: Repo.all(ConstructionProject)

  def create_construction_project(attrs),
    do: %ConstructionProject{} |> ConstructionProject.changeset(attrs) |> Repo.insert()

  def get_geojson_map_data() do
    get_construction_projects()
    |> Enum.filter(&(&1.data["coordinates"] != nil))
    |> Enum.map(fn p ->
      %{
        type: "Feature",
        properties: %{},
        geometry: %{
          type: "LineString",
          coordinates: p.data["coordinates"]
        }
      }
    end)
  end
end
