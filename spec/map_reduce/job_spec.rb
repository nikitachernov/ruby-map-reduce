require 'spec_helper'

module MapReduce
  describe Job do
    let(:data) do
      [
        { user_id: 1, post_ids: [1, 2, 3], comment_count: 2, like_count: 3 },
        { user_id: 1, post_ids: [3, 4, 5], comment_count: 4, like_count: 2 },
        { user_id: 2, post_ids: [1, 3, 5], comment_count: 2, like_count: 7 }
      ]
    end

    let(:map_function) do
      lambda do |value|
        {
          _id: value[:user_id],
          posts: value[:post_ids],
          comments: value[:comment_count],
          likes: value[:like_count]
        }
      end
    end

    let(:reduce_function) do
      lambda do |key, values|
        result = {
          _id: key,
          posts: [],
          comments: 0,
          likes: 0
        }

        values.each do |value|
          result[:posts] += value[:posts]
          result[:comments] += value[:comments]
          result[:likes] += value[:likes]
        end

        result[:posts] = result[:posts].uniq
        result[:comments] = result[:comments].to_f / values.size

        result
      end
    end

    let(:job) { Job.new(map_function, reduce_function) }

    let(:mapped_data) { job.map(data) }
    let(:reduced_data) { job.reduce(mapped_data) }

    describe '#map' do
      it 'should map data' do
        expect(mapped_data).to eq(
          1 => [
            { _id: 1, posts: [1, 2, 3], comments: 2, likes: 3 },
            { _id: 1, posts: [3, 4, 5], comments: 4, likes: 2 }
          ],
          2 => [
            { _id: 2, posts: [1, 3, 5], comments: 2, likes: 7 }
          ]
        )
      end
    end

    describe '#reduce' do
      it 'should reduce data' do
        expect(reduced_data).to eq(
          [
            {
              _id: 1,
              posts: [1, 2, 3, 4, 5],
              comments: 3,
              likes: 5
            },
            {
              _id: 2,
              posts: [1, 3, 5],
              comments: 2,
              likes: 7
            }
          ]
        )
      end
    end

    describe '#map_reduce' do
      it 'should map and reduce data' do
        map_reduced_data = job.map_reduce(data)
        expect(map_reduced_data).to eq(reduced_data)
      end
    end
  end
end
