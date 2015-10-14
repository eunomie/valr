require 'rugged'
require 'fileutils'

module GitHelpers
  def repo_path
    'fixtures/repo.git'
  end

  def create_simple_fixtures
    repo = Rugged::Repository.init_at repo_path
    create_commit repo, "first commit\n\nplop plop"
    create_commit repo, "2nd commit\n\nplop plop"
    create_commit repo, "3rd commit\n\nplop plop"
  end

  def create_empty_repository
    Rugged::Repository.init_at repo_path
  end

  def create_non_repository
    FileUtils.mkdir_p repo_path
  end

  def clear_fixtures
    FileUtils.rm_rf repo_path
  end

  private

  # @param [String] rev
  # @return [Rugged::Index]
  def get_index(repo, rev = nil)
    index = Rugged::Index.new
    unless repo.empty?
      tree = get_tree repo, rev
      index.read_tree tree
    end
    index
  end

  def get_tree(repo, rev = nil)
    if rev.nil?
      repo.head.target.tree
    else
      repo.lookup(rev).tree
    end
  end

  def commit_head(repo, tree, message = nil)
    parents = repo.empty? ? [] : [repo.head.target]
    commit repo, tree, message, parents
  end

  def create_commit(repo, message)
    index = get_index repo
    commit_head repo, index.write_tree(repo), message
  end

  def commit(repo, tree, message = nil, parents = [])
    author = {:email => 'valr@example.com', :name => 'valr', :time => Time.now}
    options = {}
    options[:tree] = tree
    options[:author] = author
    options[:committer] = author
    options[:message] ||= message
    options[:parents] = parents
    options[:update_ref] = 'HEAD'

    Rugged::Commit.create repo, options
  end
end
