defmodule TrafficWatch.CoordTransform do
  use Rustler, otp_app: :traffic_watch, crate: "coord_transform"

  def transform_coords(x, y) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
