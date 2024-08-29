use proj::Proj;

// Define the transform_coords function
#[rustler::nif]
fn transform_coords(x: f64, y: f64) -> (f64, f64) {
    let from_proj = "EPSG:3857";
    let to_proj = "EPSG:4326";
    let proj = Proj::new_known_crs(from_proj, to_proj, None).unwrap();
    proj.convert((x, y)).unwrap()
}
rustler::init!("Elixir.TrafficWatch.CoordTransform");
