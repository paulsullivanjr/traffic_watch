defmodule TrafficWatchWeb.MapLive do
  use TrafficWatchWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :current_user, nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-end p-10">
      <div>
        <h2 class="h2">Test Map</h2>
        <div id="map" phx-hook="MapTrace" class="w-[500px] h-[500px] bg-gray-200 border"></div>
      </div>
    </div>
    """
  end

  def handle_event("after_render", _params, socket) do
    send(self(), {:initiate_data})
    {:noreply, socket}
  end

  def handle_info({:initiate_data}, socket) do
    markers = get_latest_incidents()
    construction = TrafficWatch.ConstructionProjects.get_geojson_map_data()

    socket =
      socket
      |> push_event("initiate_data", %{list_stops: markers, geojson_list: construction})

    {:noreply, socket}
  end

  def get_latest_incidents() do
    {:ok, results} = TrafficWatch.AustinDataClient.get_traffic_incidents()
    today = Date.utc_today()

    _filtered_data =
      Enum.filter(results, fn item ->
        case DateTime.from_iso8601(item["published_date"]) do
          {:ok, datetime, _offset} ->
            DateTime.to_date(datetime) == today

          {:error, _reason} ->
            false
        end
      end)
      |> Enum.map(fn item ->
        [item["issue_reported"], [item["longitude"], item["latitude"]]]
      end)
      |> Jason.encode!()
  end
end
