require 'spec_helper'

describe GeoRuby::SimpleFeatures::Point do

  subject { point 1, 1 }

  let(:tour_eiffel_in_wgs84) { point 48.8580,2.2946,4326 }
  let(:tour_eiffel_in_google) { point 5438847.68117776, 255502.011303386, 900913 }

  describe "#==" do

    let(:other) { mock :other }
    
    it "should return false if other is nil" do
      subject.should_not == nil
    end

    it "should return true if distance to other is smaller than 10e-3 (< 1m)" do
      subject.stub :distance => 10e-4
      subject.should == other
    end

    it "should return false if distance to other is greater or equals to 10e-3 (>= 1m)" do
      subject.stub :distance => 10e-3
      subject.should_not == other
    end

    it "should match the same point into 2 different srid" do
      subject.to_google.should == subject
    end

  end

  describe "euclidian_distance" do

    let(:other) { point 2, 2 }
    
    it "should transform the other point into wgs84" do
      subject.euclidian_distance(other.to_google).should be_within(0.0001).of(subject.euclidian_distance(other))
    end

  end

  describe "to_rgeo" do
    it "should create a RGeo::Geos::PointImpl" do
      subject.to_rgeo.should be_instance_of(RGeo::Geos::PointImpl)
    end 

    it "should have the same information" do
      subject.to_rgeo.should have_same(:x, :y, :srid).than(subject)
    end
  end

  describe ".centroid" do

    def centroid(points)
      points = points(points) if String === points
      GeoRuby::SimpleFeatures::Point.centroid points
    end
    
    it "should return nil if no points in input" do
      centroid([]).should be_nil
    end
    
    it "should return point in input if only one" do
      centroid("0 0").should == point(0,0)
    end

    it "should return middle if two points in input" do
      centroid("0 0,1 0").should == point(0.5,0)
    end
    
    it "should return centroid of given points" do
      centroid("0 0,0 2,2 2,2 0").should == point(1,1)
    end
    
  end

  describe "#to_wgs84" do

    it "should return a point with 4326 srid" do
      subject.to_wgs84.srid.should == 4326
    end

    it "should return the same location in wgs84 srid" do
      tour_eiffel_in_google.to_wgs84.should == tour_eiffel_in_wgs84
    end

  end

  describe "#to_proj4" do
    
    it "should return a Proj4::Point" do
      subject.to_proj4.should be_instance_of(Proj4::Point)
    end

    it "should use the given ratio (if specified)" do
      subject.to_proj4(10).x.should == subject.x * 10
      subject.to_proj4(10).y.should == subject.y * 10
    end

    context "when Point is wgs84" do

      it "should transform x to radians (using ratio #{Proj4::DEG_TO_RAD})" do
        subject.to_proj4.x.should == subject.x * Proj4::DEG_TO_RAD
      end

      it "should transform y to radians (using ratio #{Proj4::DEG_TO_RAD})" do
        subject.to_proj4.y.should == subject.y * Proj4::DEG_TO_RAD
      end

    end

    it "should have the same z" do
      subject.to_proj4.z.should == subject.z
    end

  end

  describe ".from_pro4j" do

    let(:proj4_point) { subject.to_proj4 }
    let(:srid) { subject.srid }

    def from_pro4j(point, srid = srid)
      GeoRuby::SimpleFeatures::Point.from_pro4j point, srid
    end

    it "should transform x to degres" do
      from_pro4j(proj4_point).x.should == proj4_point.x * Proj4::RAD_TO_DEG
    end

    it "should transform y to degres" do
      from_pro4j(proj4_point).y.should == proj4_point.y * Proj4::RAD_TO_DEG
    end

    it "should have the specified srid" do
      from_pro4j(proj4_point, srid).srid.should == srid
    end
    
  end

end
