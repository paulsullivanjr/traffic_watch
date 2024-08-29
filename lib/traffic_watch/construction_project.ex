defmodule TrafficWatch.ConstructionProject do
  use Ecto.Schema
  import Ecto.Changeset

  schema "construction_projects" do
    field :data, :map

    timestamps()
  end

  def changeset(construction_project, attrs) do
    construction_project
    |> cast(attrs, [:data])
  end
end
