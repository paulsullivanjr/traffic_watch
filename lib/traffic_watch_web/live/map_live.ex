defmodule TrafficWatchWeb.MapLive do
  use TrafficWatchWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :current_user, nil)

    markers = get_latest_incidents()
    socket = push_event(socket, "add_markers", %{markers: markers})
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-end p-10">
      <div id="map" class="w-[500px] h-[500px] bg-gray-200 border" phx-hook="Map"></div>
    </div>
    """
  end

  def get_latest_incidents() do
    {:ok, results} = TrafficWatch.AustinDataClient.get_traffic_incidents()
    today = Date.utc_today()

    filtered_data =
      Enum.filter(results, fn item ->
        case DateTime.from_iso8601(item["published_date"]) do
          {:ok, datetime, _offset} ->
            DateTime.to_date(datetime) == today

          {:error, _reason} ->
            false
        end
      end)
      |> Enum.map(fn item ->
        %{
          lat: item["latitude"],
          lng: item["longitude"],
          popup: item["issue_reported"]
        }
      end)
  end
end
