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

    context 'with an empty repository' do
      before(:each) do
        create_empty_repository
      end

      it 'raise an error' do
        expect{Valr::Repo.new repo_path}.to raise_error Valr::EmptyRepositoryError, "'#{repo_path}' is empty"
      end
    end
  end

  describe '#changelog' do
    context 'with linear histo' do
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

    context 'with branches and merge' do
      before(:each) do
        create_repo_from 'with_branch'
      end

      context 'when asked for all commits' do
        it 'returns first line of commit messages' do
          valr = Valr::Repo.new repo_path
          expect(valr.changelog).to eq "- merge commit\n- feature commit 2\n- feature commit 1\n- first commit"
        end
      end

      context 'when asked for first parent commits' do
        it 'returns only messages for commits in the branch' do
          valr = Valr::Repo.new repo_path
          expect(valr.changelog first_parent: true).to eq "- merge commit\n- first commit"
        end
      end
    end
  end

  describe '#full_changelog' do
    context 'with linear histo' do
      before(:each) do
        create_simple_fixtures
      end

      context 'without any specific formating' do
        it 'returns the sha1 of the commit as a context of the changelog' do
          valr = Valr::Repo.new repo_path
          expect(valr.full_changelog.lines.first.chomp).to match /^[0-9a-f]{40}$/
        end

        it 'returns a blank line and the changlog after the metadata' do
          valr = Valr::Repo.new repo_path
          expect(valr.full_changelog.lines[1..-1].join).to eq "\n#{valr.changelog}"
        end
      end
    end

    context 'with branches and merge' do
      before(:each) do
        create_repo_from 'with_branch'
      end

      context 'when asked for all commits' do
        it 'returns the sha1 of the commit as a context of the changelog' do
          valr = Valr::Repo.new repo_path
          expect(valr.full_changelog.lines.first.chomp).to match /^[0-9a-f]{40}$/
        end

        it 'returns a blank line and the changelog after the metadata' do
          valr = Valr::Repo.new repo_path
          expect(valr.full_changelog.lines[1..-1].join).to eq "\n#{valr.changelog}"
        end
      end

      context 'when asked for first parent commits' do
        it 'returns the sha1 of the commit as a context of the changelog' do
          valr = Valr::Repo.new repo_path
          expect(valr.full_changelog(first_parent: true).lines.first.chomp).to match /^[0-9a-f]{40}$/
        end

        it 'returns a blank line and the changelog after the metadata' do
          valr = Valr::Repo.new repo_path
          expect(valr.full_changelog(first_parent: true).lines[1..-1].join).to eq "\n#{valr.changelog first_parent: true}"
        end
      end
    end
  end
end
