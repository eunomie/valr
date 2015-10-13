require 'valr'

describe Valr do
  describe '#changelog' do
    let(:repo_path) {
      @repo_path = 'fixtures/simple_repo.git'
    }
    context 'without any specific formating' do
      it 'returns the first line of commit messages in markdown list' do
        valr = Valr.new
        expect(valr.changelog(repo_path)).to eq "- 3rd commit\n- 2nd commit\n- first commit"
      end
    end
  end
end
