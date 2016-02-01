Before do
  clear_fixtures
end

Given(/^a simple repository$/) do
  clear_fixtures
  create_simple_fixtures
end

When(/^ask for the changelog$/) do
  @changelog = Valr::Repo.new(repo_path).changelog
end

Then(/^returns all commit messages$/) do
  @changelog.lines.size.should eq 3
  @changelog.should eq "- 3rd commit
- 2nd commit
- first commit"
end
