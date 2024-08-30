defmodule TrafficWatch.AustinDataClient do
  @moduledoc """
  This module is responsible for fetching data from the Austin Open Data Portal.
  """

  @base_url "https://datahub.austintexas.gov/resource/dx9v-zd7x.json?traffic_report_status=ACTIVE"

  @doc """
  Fetches the traffic incidents from the Austin Open Data Portal.
  """
  def get_traffic_incidents do
    headers = [{"X-App-Token", get_app_token()}]

    case Finch.build(:get, @base_url, headers)
         |> Finch.request(TrafficWatch.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Finch.Response{status: status}} ->
        {:error, "Failed with status: #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Place holder, not to be used at this time
  def seed_data do
    TrafficWatch.Repo.delete_all(TrafficWatch.ConstructionProject)

    "./lib/data/austin.geojson"
    |> process_geojson_file()
  end

  def process_geojson_file(file_path) do
    file_path
    |> File.stream!()
    |> Stream.chunk_every(100)
    |> Stream.each(&create_oban_job/1)
    |> Stream.run()
  end

  defp create_oban_job(payload) do
    feature_collection =
      payload
      |> Jason.decode!(keys: :strings)

      feature_collection["features"]
      |> Enum.map(fn feature ->
        updated_properties =
          Map.new(feature["properties"], fn {k, v} ->
            {k, v}
          end)

        %{feature | "properties" => updated_properties}
      end)
      |> Enum.chunk_every(20)
      |> Enum.each(fn chunk ->
        %{"features" => chunk}
        |> TrafficWatch.GeoJSONChunkProcessor.new()
        |> Oban.insert()
      end)
  end

  defp get_app_token do
    System.get_env("AUSTIN_DATA_APP_TOKEN", "")
  end
end
