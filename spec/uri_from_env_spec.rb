require 'spec_helper'

describe UriFromEnv do
  let(:uri) { UriFromEnv.new({}) }
  it 'print_url_parts have a not nil and not blank value' do
    expect(uri.print_url_part('test', '?')).to eq('?test')
  end

  it 'print_url_parts have a nil value' do
    expect(uri.print_url_part(nil, '')).to eq('')
  end

  it 'print_url_parts have a blamk value' do
    expect(uri.print_url_part('', '')).to eq('')
  end
end