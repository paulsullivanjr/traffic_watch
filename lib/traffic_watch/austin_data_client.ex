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

  def seed_data do
    "/Users/paulsullivan/Downloads/TxDOT_DCIS_All_Projects_-2097923559319759537.geojson"
    |> process_geojson_file()
  end

  def process_geojson_file(file_path) do
    file_path
    |> File.stream!()
    |> Stream.chunk_every(1000)
    |> Stream.each(&create_oban_job/1)
    |> Stream.run()
  end

  defp create_oban_job(payload) do
    feature_collection =
      payload
      |> Jason.decode!(keys: :strings)

    updated_features =
      feature_collection["features"]
      |> Enum.filter(&filter_feature/1)
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

  defp filter_feature(%{
         "properties" => %{
           "DISTRICT_NAME" => "Austin",
           "PROJ_STAT" => "Active",
           "PROJ_STG" => "Construction"
         }
       }),
       do: true

  defp filter_feature(_), do: false

  defp get_app_token do
    System.get_env("AUSTIN_DATA_APP_TOKEN")
  end
end
