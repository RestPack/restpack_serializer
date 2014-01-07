require 'spec_helper'

describe RestPack::Serializer::Result do
  context 'a new instance' do
    it 'has defaults' do
      subject.resources.should == {}
      subject.meta.should == {}
      subject.links.should == {}
    end
  end

  context 'when serializing' do
    let(:result) { subject.serialize }
    context 'in jsonapi.org format' do
      context 'an empty result' do
        it 'returns an empty result' do
          result.should == {}
        end
      end

      context 'a simple list of resources' do
        before do
          subject.resources[:albums] = [{ name: 'Album 1' }, { name: 'Album 2'}]
          subject.meta[:albums] = { count: 2 }
          subject.links['albums.songs'] = { href: 'songs.json', type: 'songs' }
        end

        it 'returns correct jsonapi.org format' do
          result[:albums].should == subject.resources[:albums]
          result[:meta].should == subject.meta
          result[:links].should == subject.links
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
          result[:albums].should == [{ id: '1', name: 'AMOK', links: { songs: ['91'] } }]
          result[:links].should == subject.links
          result[:linked][:songs].should == subject.resources[:songs]
        end

        it 'includes resources in correct order' do
          result.keys[0].should == :albums
          result.keys[1].should == :linked
          result.keys[2].should == :links
          result.keys[3].should == :meta
        end

        context 'with multiple calls to serialize' do
          let(:result) do
            subject.serialize
            subject.serialize
          end

          it 'does not create duplicate has_many links' do
            result[:albums].first[:links][:songs].count.should == 1
          end
        end
      end
    end
  end
end
