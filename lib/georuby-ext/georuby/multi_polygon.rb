class GeoRuby::SimpleFeatures::MultiPolygon
  def to_wgs84
    self.class.from_polygons(self.polygons.collect(&:to_wgs84), 4326)
  end

  def polygons
    self.geometries.flatten
  end
end
