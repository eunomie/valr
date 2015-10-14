require 'valr'

describe Valr do
  after(:each) do
    clear_fixtures
  end

  describe '#new' do
    context 'without a git repository' do
      before(:each) do
        create_non_repository
      end

      it 'raise an error' do
        expect{Valr::Repo.new repo_path}.to raise_error Valr::RepositoryError, "'#{repo_path}' is not a git repository"
      end
    end
  end

  describe '#changelog' do
    before(:each) do
      create_simple_fixtures
    end

    context 'without any specific formating' do
      it 'returns the first line of commit messages in markdown list' do
        valr = Valr::Repo.new repo_path
        expect(valr.changelog).to eq "- 3rd commit\n- 2nd commit\n- first commit"
      end
    end
  end

  describe '#full_changelog' do
    before(:each) do
      create_simple_fixtures
    end

    context 'without any specific formating' do
      it 'returns the sha1 of the commit as a context of the changelog' do
        valr = Valr::Repo.new repo_path
        expect(valr.full_changelog.lines.first.chomp).to match /^[0-9a-f]{40}$/
      end

      it 'returns a blank line and the commits in a markdown list after the metadata' do
        valr = Valr::Repo.new repo_path
        expect(valr.full_changelog.lines[1..-1].join).to eq "\n- 3rd commit\n- 2nd commit\n- first commit"
      end
    end
  end
end
