require 'spec_helper'

describe Ratis::Point2Point do
  describe 'Routesonly => Y' do
    describe '#where', vcr: {} do
      describe 'services from origin to destination' do
        before do
          @today      = Chronic.parse('next monday at 6am').strftime("%m/%d/%Y")
          @conditions = {:routes_only      => true,
                         :origin_lat       => 33.446931,
                         :origin_long      => -112.097903,
                         :destination_lat  => 33.447098,
                         :destination_long => -112.077213,
                         :date             => @today,
                         :start_time       => '1700',
                         :end_time         => '1800'}

        end

        it 'returns all matching services that fit the origin/destination for a given time frame' do
          services = Ratis::Point2Point.where(@conditions.dup)
          services.should have(20).items
        end

        it 'only makes one request' do
          # false just to stop further processing of response
          Ratis::Request.should_receive(:get).once.and_call_original
          Ratis::Point2Point.where(@conditions.dup)
        end

        it 'requests the correct SOAP action' do
          Ratis::Request.should_receive(:get) do |action, options|
                           action.should eq('Point2point')
                           options["Date"].should eq(@today)
                           options["Destinationlong"].should eq(-112.077213)
                           options["Starttime"].should eq("1700")
                           options["Endtime"].should eq("1800")
                           options["Destinationlat"].should eq(33.447098)
                           options["Routesonly"].should eq("Y")
                           options["Originlong"].should eq(-112.097903)
                           options["Originlat"].should eq(33.446931)

                         end.and_return(double('response', :success? => false)) # false only to stop further running

          Ratis::Point2Point.where(@conditions.dup)
        end

        it 'returns a routes only response for each matched service' do
          services = Ratis::Point2Point.where(@conditions.dup)
          services.should be_a( Array )
          services.each{|response| response.should be_a( Ratis::Point2Point::RoutesOnlyResponse ) }
        end

        it 'parses out service fields' do
          services = Ratis::Point2Point.where(@conditions.dup)
          service  = services.first

          service.route.should eql '562'
          service.direction.should eql 'O'
          service.service_type.should eql 'W'
          service.signage.should eql "562 Goodyear To Goodyear"
          service.route_type.should eql 'X'
        end

        it "should NOT filter by passed in routes" do
          # According to Marc Ferguson of Trapeze group, route filter only works when Routesonly = 'N'
          services = Ratis::Point2Point.where(@conditions.dup.merge(:routes => ['1']))
          services.should have(20).items
        end
      end
    end
  end

  describe 'Routesonly => N' do

    describe '#where', vcr: {} do

      before do
        @today      = Time.now.strftime("%m/%d/%Y")
        @conditions = {:routes_only      => false,
                       :origin_lat       => 33.446931,
                       :origin_long      => -112.097903,
                       :destination_lat  => 33.447098,
                       :destination_long => -112.077213,
                       :date             => @today,
                       :start_time       => '1700',
                       :end_time         => '1800'}

      end

      it 'only makes one request' do
        Ratis::Request.should_receive(:get).once.and_call_original
        Ratis::Point2Point.where(@conditions.dup)
      end

      it 'requests the correct SOAP action with correct args' do
        Ratis::Request.should_receive(:get) do |action, options|
          action.should eq('Point2point')
          options["Date"].should eq(@today)
          options["Destinationlong"].should eq(-112.077213)
          options["Starttime"].should eq("1700")
          options["Endtime"].should eq("1800")
          options["Destinationlat"].should eq(33.447098)
          options["Routesonly"].should eq("N")
          options["Originlong"].should eq(-112.097903)
          options["Originlat"].should eq(33.446931)

        end.and_return(double('response', :success? => false)) # false only to stop further running

        Ratis::Point2Point.where(@conditions.dup)
      end

      it 'gets the groups' do
        schedule = Ratis::Point2Point.where(@conditions.dup)
        schedule.should have(3).groups
        schedule.groups.each{|group| group.should be_a(Ratis::Point2Point::Group) }
      end

      it 'gets the trips within each group' do
        schedule = Ratis::Point2Point.where(@conditions.dup)
        schedule.groups[0].size.should be_within(10).of(11)
        schedule.groups[1].size.should be_within(10).of(11)
        schedule.groups[2].size.should be_within(10).of(11)
      end

      it 'parses out the on stop fields' do
        schedule = Ratis::Point2Point.where(@conditions.dup)
        group    = schedule.groups.first
        on_stop  = group.on_stop

        on_stop.should be_a(Ratis::Point2Point::Stop)

        on_stop.description.should eql('JEFFERSON ST & 18TH AVE')
        on_stop.latitude.should eql(33.4469)
        on_stop.longitude.should eql(-112.097897)
        on_stop.atis_stop_id.should eql(9469)
        on_stop.walk_dist.should eql(0.0)
        on_stop.walk_dir.should eql('S')
        on_stop.walk_hint.should eql('N')
      end

      it 'parses out the off stop fields' do
        schedule  = Ratis::Point2Point.where(@conditions.dup)
        group     = schedule.groups.first
        off_stop  = group.off_stop

        off_stop.should be_a(Ratis::Point2Point::Stop)

        off_stop.description.should eql('JEFFERSON ST &amp; 18TH AVE')
        off_stop.latitude.should eql(33.447029)
        off_stop.longitude.should eql(-112.077181)
        off_stop.atis_stop_id.should eql(1463)
        off_stop.walk_dist.should eql(0.0)
        off_stop.walk_dir.should eql('SE')
        off_stop.walk_hint.should eql('N')
      end

      it 'parses out the trip' do
        schedule = Ratis::Point2Point.where(@conditions.dup)
        group    = schedule.groups.first
        trip     = group.trips.first

        trip.should be_a(Ratis::Point2Point::Trip)

        trip.on_time.should eql('05:01 PM')
        trip.off_time.should eql('05:08 PM')
      end

      it 'parses out the service' do
        schedule = Ratis::Point2Point.where(@conditions.dup)
        group    = schedule.groups.first
        service  = group.trips.first.service

        service.should be_a(Ratis::Point2Point::Service)

        service.route.should eql('I10E')
        service.direction.should eql('O')
        service.service_type.should eql('W')
        service.signage.should eql('I-10 EAST RAPID To 40 St/Pecos')
        service.route_type.should eql('N')
        service.exception.should eql('N')
      end

      it "should only return result groups for filtered route" do
        schedule = Ratis::Point2Point.where(@conditions.dup.merge(:routes => ['I10E']))
        schedule.groups.size.should eq(1)
      end

      it "should only return result groups for filtered routes" do
        schedule = Ratis::Point2Point.where(@conditions.dup.merge(:routes => ['1', 'I10E']))
        schedule.groups.size.should be > 0
      end

      it "should raise error if the trip is NOT possible for a route being attempted to filter on" do
        # According to Marc Ferguson of Trapeze group, route filter only works when Routesonly = 'N'
        lambda {
          Ratis::Point2Point.where(@conditions.dup.merge(:routes => ['GAL']))
        }.should raise_error(Ratis::Errors::SoapError)
      end

      it "should raise error if the trip is NOT possible for a route being attempted to filter on" do
        # According to Marc Ferguson of Trapeze group, route filter only works when Routesonly = 'N'
        begin
          Ratis::Point2Point.where(@conditions.dup.merge(:routes => ['GAL']))
        rescue Exception => e
          e.message.should eq('Trip not possible')
        end
      end


    end
  end

end

