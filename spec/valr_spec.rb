require 'valr'

describe Valr do
  before(:each) do
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

    context 'with a valid git repository' do
      before(:each) do
        create_simple_fixtures
      end

      it 'creates an instance of Valr::Repo' do
        expect{Valr::Repo.new repo_path}.not_to raise_error
      end
    end
  end

  describe '#changelog' do
    context 'with a linear git history' do
      before(:each) do
        create_simple_fixtures
      end

      it 'returns the first line of each commit messages in a markdown list' do
        valr = Valr::Repo.new repo_path
        expect(valr.changelog).to eq Koios::Doc.write {
          [ul(["3rd commit",
               "2nd commit",
               "first commit"])]
        }
      end

      context 'when asked for a commit range' do
        it 'returns only the messages of commits in the range' do
          valr = Valr::Repo.new repo_path
          expect(valr.changelog range: 'HEAD~2..HEAD').to eq Koios::Doc.write {
          [ul(["3rd commit",
               "2nd commit"])]
        }
        end

        it 'returns an error if range is not valid' do
          valr = Valr::Repo.new repo_path
          expect{valr.changelog range: 'Plop..Bla'}.to raise_error Valr::NotValidRangeError, "'Plop..Bla' is not a valid range"
        end
      end
    end

    context 'with a git history containing branches and merge' do
      before(:each) do
        create_repo_from 'with_branch'
      end

      context 'when asked for all commits' do
        it 'returns first line of each commit messages in a markdown list' do
          valr = Valr::Repo.new repo_path
          expect(valr.changelog).to eq Koios::Doc.write {
            [ul(["commit",
                 "merge commit",
                 "feature commit 2",
                 "feature commit 1",
                 "first commit"])]
          }
        end

        it 'returns first line of each commit messages including in the range' do
          valr = Valr::Repo.new repo_path
          expect(valr.changelog range: 'c85250a..HEAD').to eq Koios::Doc.write {
            [ul(["commit",
                 "merge commit",
                 "feature commit 2",
                 "feature commit 1"])]
          }
        end
      end

      context 'when asked for first parent commits' do
        it 'returns only messages for commits written in the branch' do
          valr = Valr::Repo.new repo_path
          expect(valr.changelog first_parent: true).to eq Koios::Doc.write {
            [ul(["commit",
                 "merge commit",
                 "first commit"])]
          }
        end

        it 'returns only messages for commits written in the branch and in the range' do
          valr = Valr::Repo.new repo_path
          expect(valr.changelog first_parent: true, range: 'HEAD^^..HEAD').to eq Koios::Doc.write {
            [ul(['commit',
                 'merge commit'])]
          }
          expect(valr.changelog first_parent: true, range: 'HEAD~1..HEAD').to eq Koios::Doc.write {[ul(['commit'])]}
        end
      end

      context 'when asked for commits in a branch' do
        it 'returns messages of commits in the branch and parents' do
          valr = Valr::Repo.new repo_path
          expect(valr.changelog branch: 'feature').to eq Koios::Doc.write {
            [ul(["feature commit 2",
                 "feature commit 1",
                 "first commit"])]
          }
        end

        it 'returns an error if branch is not valid' do
          valr = Valr::Repo.new repo_path
          expect{valr.changelog branch: 'non_existing/branch'}.to raise_error Valr::NotValidBranchError, "'non_existing/branch' is not a valid branch"
        end
      end

      context 'when asked for range and branch' do
        it 'range is prioritary in front of branch' do
          valr = Valr::Repo.new repo_path
          expect(valr.changelog range: 'c85250a..HEAD', branch: 'feature').to eq Koios::Doc.write {
            [ul(["commit",
                 "merge commit",
                 "feature commit 2",
                 "feature commit 1"])]
          }
        end
      end
    end

    context 'with a git history containing branches' do
      before(:each) do
        create_repo_from 'branch_without_merge'
      end

      context 'when asked for commits in a branch' do
        it 'returns messages of commits in the branch and from common ancestor' do
          valr = Valr::Repo.new repo_path
          expect(valr.changelog branch: 'feature', from_ancestor_with: 'master').to eq Koios::Doc.write {
            [ul(["feature commit 2",
                 "feature commit 1"])]
          }
          expect(valr.changelog branch: 'master', from_ancestor_with: 'feature').to eq Koios::Doc.write {
            [ul(["master commit 2",
                 "master commit 1"])]
          }
        end
      end
    end
  end

  describe '#full_changelog' do
    context 'with a linear git history' do
      before(:each) do
        create_simple_fixtures
      end

      context 'without range' do
        it 'returns the sha1 of the commit as a context of the changelog' do
          valr = Valr::Repo.new repo_path
          expect(valr.full_changelog.lines.first.chomp).to match(/^[0-9a-f]{40}$/)
        end

        it 'returns a blank line followed by the changlog after the metadata' do
          valr = Valr::Repo.new repo_path
          expect(valr.full_changelog.lines[1..-1].join).to eq valr.changelog
        end
      end

      context 'with a range' do
        it 'returns an error if range is not valid' do
          valr = Valr::Repo.new repo_path
          expect{valr.full_changelog range: 'Plop..Bla'}.to raise_error Valr::NotValidRangeError, "'Plop..Bla' is not a valid range"
        end

        it 'returns metadata containg the range and the corresponding oids' do
          valr = Valr::Repo.new repo_path
          from = 'HEAD~2'
          to = 'HEAD'
          full_changelog = valr.full_changelog range: "#{from}..#{to}"
          r_from = /^    from: #{Regexp.escape from} <[0-9a-f]{40}>\n/
          r_to   = /^    to:   #{Regexp.escape to  } <[0-9a-f]{40}>\n/
          expect(full_changelog.lines[0]).to match r_from
          expect(full_changelog.lines[1]).to match r_to
        end

        it 'returns a blank line followed by the changlog after the metadata' do
          valr = Valr::Repo.new repo_path
          range = 'HEAD~2..HEAD'
          expect(valr.full_changelog(range: range).lines[2..-1].join).to eq "\n#{valr.changelog(range: range)}"
        end
      end
    end

    context 'with a git history containing branches and merge' do
      before(:each) do
        create_repo_from 'with_branch'
      end

      context 'without a range' do
        context 'when asked for all commits' do
          it 'returns the sha1 of the commit as a context of the changelog' do
            valr = Valr::Repo.new repo_path
            expect(valr.full_changelog.lines.first.chomp).to match(/^[0-9a-f]{40}$/)
          end

          it 'returns a blank line followed by the changlog after the metadata' do
            valr = Valr::Repo.new repo_path
            expect(valr.full_changelog.lines[1..-1].join).to eq valr.changelog
          end
        end

        context 'when asked for first parent commits' do
          it 'returns the sha1 of the commit as a context of the changelog' do
            valr = Valr::Repo.new repo_path
            expect(valr.full_changelog(first_parent: true).lines.first.chomp).to match(/^[0-9a-f]{40}$/)
          end

          it 'returns a blank line followed by the changlog after the metadata' do
            valr = Valr::Repo.new repo_path
            expect(valr.full_changelog(first_parent: true).lines[1..-1].join).to eq valr.changelog(first_parent: true)
          end
        end
      end

      context 'with a range' do
        it 'returns metadata containg the range and the corresponding oids' do
          valr = Valr::Repo.new repo_path
          from = 'HEAD~2'
          to = 'HEAD'
          full_changelog = valr.full_changelog range: "#{from}..#{to}"
          r_from = /^    from: #{Regexp.escape from} <[0-9a-f]{40}>\n/
          r_to   = /^    to:   #{Regexp.escape to  } <[0-9a-f]{40}>\n/
          expect(full_changelog.lines[0]).to match r_from
          expect(full_changelog.lines[1]).to match r_to
        end

        it 'returns a blank line followed by the changlog after the metadata' do
          valr = Valr::Repo.new repo_path
          range = 'HEAD^^..HEAD'
          expect(valr.full_changelog(range: range).lines[2..-1].join).to eq "\n#{valr.changelog range: range}"
        end
      end

      context 'with a branch' do
        it 'returns metadata containg the branch and the corresponding oids' do
          valr = Valr::Repo.new repo_path
          branch = 'feature'
          full_changelog = valr.full_changelog branch: branch
          r_branch = /^    branch: #{Regexp.escape branch} <[0-9a-f]{40}>\n/
          expect(full_changelog.lines[0]).to match r_branch
        end

        it 'returns a blank line followed by the changlog after the metadata' do
          valr = Valr::Repo.new repo_path
          branch = 'feature'
          expect(valr.full_changelog(branch: branch).lines[1..-1].join).to eq "\n#{valr.changelog branch: branch}"
        end
      end

      context 'with range and branch' do
        it 'range is prioritary in front of branch' do
          valr = Valr::Repo.new repo_path
          from = 'HEAD~2'
          to = 'HEAD'
          branch = 'feature'
          full_changelog = valr.full_changelog range: "#{from}..#{to}", branch: branch
          r_from = /^    from: #{Regexp.escape from} <[0-9a-f]{40}>\n/
          r_to   = /^    to:   #{Regexp.escape to  } <[0-9a-f]{40}>\n/
          expect(full_changelog.lines[0]).to match r_from
          expect(full_changelog.lines[1]).to match r_to
          expect(full_changelog.lines[2..-1].join).to eq "\n#{valr.changelog range: "#{from}..#{to}", branch: branch}"
        end
      end
    end

    context 'with a git history containing branches' do
      before(:each) do
        create_repo_from 'with_branch'
      end

      context 'with a branch' do
        it 'returns metadata containg the branch and ancestor' do
          valr = Valr::Repo.new repo_path
          branch = 'feature'
          ancestor_with = 'master'
          full_changelog = valr.full_changelog branch: branch, from_ancestor_with: ancestor_with
          r_branch = /^    branch: #{Regexp.escape branch} <[0-9a-f]{40}>\n/
          r_ancestor = /^    from ancestor with: #{Regexp.escape ancestor_with} <[0-9a-f]{40}>\n/
          expect(full_changelog.lines[0]).to match r_branch
          expect(full_changelog.lines[1]).to match r_ancestor
        end

        it 'returns a blank line followed by the changlog from common ancestor after the metadata' do
          valr = Valr::Repo.new repo_path
          branch = 'feature'
          ancestor_with = 'master'
          expect(valr.full_changelog(branch: branch, from_ancestor_with: ancestor_with).lines[2..-1].join).to eq "\n#{valr.changelog branch: branch, from_ancestor_with: ancestor_with}"
        end
      end
    end
  end
end
