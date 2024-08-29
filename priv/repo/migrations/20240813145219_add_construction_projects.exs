defmodule TrafficWatch.Repo.Migrations.AddConstructionProjects do
  use Ecto.Migration

  def change do
    create table(:construction_projects) do
      add :data, :jsonb

      timestamps()
    end
  end
end
