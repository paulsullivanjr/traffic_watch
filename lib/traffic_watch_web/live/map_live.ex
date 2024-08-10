defmodule TrafficWatchWeb.MapLive do
  use TrafficWatchWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :current_user, nil)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="map" class="w-[500px] h-[500px] p-20" phx-hook="Map"></div>
    """
  end
end
