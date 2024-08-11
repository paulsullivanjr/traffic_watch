defmodule TrafficWatch.AustinDataClient do
  @moduledoc """
  This module is responsible for fetching data from the Austin Open Data Portal.
  """

  @base_url "https://datahub.austintexas.gov/resource/dx9v-zd7x.json?traffic_report_status=ACTIVE"
  # @base_url "https://datahub.austintexas.gov/resource/dx9v-zd7x.json?traffic_report_id=EE02C29275E85AEDD7D971820672CE0454733B81_1723251557"

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

  defp get_app_token do
    System.get_env("AUSTIN_DATA_APP_TOKEN")
  end
end
