require 'spec_helper'

describe Location do
  before do
    @building = Building.create!(name: 'big house')

    1.upto(5) do |index|
      floor = Floor.create!(name: "#{index}. Floor")

      @building.children << floor

      1.upto(5) do |index_room|

        floor.children << Room.create!(name: "#{index_room}. Room")
      end
    end
  end

  describe 'building' do
    it 'has 30 descendants' do
      expect(@building.descendants.count).to eq(5 + (5 * 5))
    end

    context 'descendants_of' do

      it 'called by Room returns only Rooms' do
        rooms = Room.descendants_of(@building)

        expect(rooms.count).to eq(25)
        expect(rooms.all).to all(be_an(Room))
      end

    end
  end

end