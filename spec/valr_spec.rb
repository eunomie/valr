require 'valr'

describe Valr do
  before(:each) do
    create_simple_fixtures
  end

  after(:each) do
    clear_fixtures
  end

  describe '#changelog' do
    context 'without any specific formating' do
      it 'returns the first line of commit messages in markdown list' do
        valr = Valr.new
        expect(valr.changelog(repo_path)).to eq "- 3rd commit\n- 2nd commit\n- first commit"
      end
    end
  end
end
