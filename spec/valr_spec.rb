require 'valr'

RSpec.describe Valr, '#changelog' do
  let(:commits) {
    @commits = ["first commit\n\nplop",
                "2nd commit\n\nplop",
                "3rd commit\n\nplop"]
  }
  context 'without any specific formating' do
    it 'returns the first line of commit messages in markdown list' do
      valr = Valr.new
      expect(valr.changelog(commits)).to eq "- 3rd commit\n- 2nd commit\n- first commit"
    end
  end
end
