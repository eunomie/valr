Feature: Simple changelog

Scenario: Display all commit messages of a repository
  Given a repository
  When ask for the changelog
  Then returns all commit messages
