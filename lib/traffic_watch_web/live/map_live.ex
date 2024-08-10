defmodule TrafficWatchWeb.MapLive do
  use TrafficWatchWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :current_user, nil)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-end p-10">
      <div id="map" class="w-[500px] h-[500px] bg-gray-200 border" phx-hook="Map"></div>
    </div>
    """
  end
end
