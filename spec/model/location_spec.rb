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

    context '::descendants_of' do

      context 'with Room' do
        let(:rooms) { Room.descendants_of(@building) }

        it 'should have 25 rooms' do
          expect(rooms.count).to eq(25)
        end

        it 'should all be of type Room' do
          expect(rooms.all).to all(be_an(Room))
        end

      end

      context 'with Floor' do
        let(:floors) { Floor.descendants_of(@building) }

        it 'should have 5 Floors' do
          expect(floors.count).to eq(5)
        end

        it 'should all be of type Floor' do
          expect(floors.all).to all(be_an(Floor))
        end

      end

    end
  end

end