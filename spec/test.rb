require 'rspec'
require 'nokogiri'
require 'json'

require_relative '../scraper.rb'

# Testing using a small structure
RSpec.describe 'Scraper' do
  let(:html_content) do
    <<~HTML
      <html>
        <script>
          var ii=['image_id_1'];
          var s='base64_image_1';
        </script>
        <div class="iELo6">
          <a href="/path/to/link1">
            <div class="pgNMRc">Painting 1</div>
            <div class="cxzHyb">Extension 1</div>
            <img id="image_id_1" />
          </a>
        </div>
        <div class="iELo6">
          <a href="/path/to/link2">
            <div class="pgNMRc">Painting 2</div>
            <img data-src="data_src_image_2" />
          </a>
        </div>
      </html>
    HTML
  end

  let(:doc) { Nokogiri::HTML(html_content) }

  describe '#pre_process' do
    it 'returns a hash mapping image ids to base64 images' do
      expected_hash = { 'image_id_1' => 'base64_image_1' }
      expect(pre_process(doc)).to eq(expected_hash)
    end
  end

  describe '#get_image' do
    let(:hash) { { 'image_id_1' => 'base64_image_1' } }

    it 'returns the base64 image from the hash when the image has an id' do
      ele = doc.at_css('div.iELo6 a')
      expect(get_image(ele, hash)).to eq('base64_image_1')
    end

    it 'returns the data-src attribute when the image does not have an id' do
      ele = doc.css('div.iELo6 a').last
      expect(get_image(ele, hash)).to eq('data_src_image_2')
    end
  end

  describe '#process_elements' do
    let(:hash) { { 'image_id_1' => 'base64_image_1' } }

    it 'returns an array of hashes with the expected structure' do
      expected_array = [
        {
          'name' => 'Painting 1',
          'extensions' => ['Extension 1'],
          'link' => 'https://www.google.com/path/to/link1',
          'image' => 'base64_image_1'
        },
        {
          'name' => 'Painting 2',
          'link' => 'https://www.google.com/path/to/link2',
          'image' => 'data_src_image_2'
        }
      ]
      expect(process_elements(doc, hash)).to eq(expected_array)
    end
  end
end