require 'spec_helper'

describe RestPack::Serializer::Result do
  context 'a new instance' do
    it 'has defaults' do
      expect(subject.resources).to eq({})
      expect(subject.meta).to eq({})
      expect(subject.links).to eq({})
    end
  end

  context 'when serializing' do
    let(:result) { subject.serialize }

    context 'in jsonapi.org format' do
      context 'an empty result' do
        it 'returns an empty result' do
          expect(result).to eq({})
        end
      end

      context 'a simple list of resources' do
        before do
          subject.resources[:albums] = [{ name: 'Album 1' }, { name: 'Album 2'}]
          subject.meta[:albums] = { count: 2 }
          subject.links['albums.songs'] = { href: 'songs.json', type: 'songs' }
        end

        it 'returns correct jsonapi.org format' do
          expect(result[:albums]).to eq(subject.resources[:albums])
          expect(result[:meta]).to eq(subject.meta)
          expect(result[:links]).to eq(subject.links)
        end
      end

      context 'a list with side-loaded resources' do
        before do
          subject.resources[:albums] = [{ id: '1', name: 'AMOK'}]
          subject.resources[:songs] = [{ id: '91', name: 'Before Your Very Eyes...', links: { album: '1' }}]
          subject.meta[:albums] = { count: 1 }
          subject.meta[:songs] = { count: 1 }
          subject.links['albums.songs'] = { type: 'songs', href: '/api/v1/songs?album_id={albums.id}' }
          subject.links['songs.album'] = { type: 'albums', href: '/api/v1/albums/{songs.album}' }
        end

        it 'returns correct jsonapi.org format, including injected has_many links' do
          expect(result[:albums]).to eq([{ id: '1', name: 'AMOK', links: { songs: ['91'] } }])
          expect(result[:links]).to eq(subject.links)
          expect(result[:linked][:songs]).to eq(subject.resources[:songs])
        end

        it 'includes resources in correct order' do
          expect(result.keys[0]).to eq(:albums)
          expect(result.keys[1]).to eq(:linked)
          expect(result.keys[2]).to eq(:links)
          expect(result.keys[3]).to eq(:meta)
        end

        context 'with multiple calls to serialize' do
          let(:result) do
            subject.serialize
            subject.serialize
          end

          it 'does not create duplicate has_many links' do
            expect(result[:albums].first[:links][:songs].count).to eq(1)
          end
        end
      end
    end
  end
end
