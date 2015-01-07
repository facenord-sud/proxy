require 'spec_helper'

describe 'Test different URI' do

  it 'simple URI' do
    get 'http://www.google.ch'
    expect(last_response.ok?).to be(true)
  end

  it 'URI with GET params' do
    get 'http://www.google.ch/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0CB0QFjAA&url=http%3A%2F%2Ffr.wikipedia.org%2Fwiki%2FSans-abri&ei=4CCtVO3NBsyOaL6ugZAM&usg=AFQjCNGxPma4j4dWfcGfNGeJXLqehkgbcA&sig2=6C632BXO4VNKNqChZh9WwA&bvm=bv.83134100,d.ZWU'
    expect(last_response.ok?).to be(true)
  end
end