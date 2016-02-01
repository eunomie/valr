Feature: Simple changelog
  As a project maintainer
  I want to get all commit messages
  So I can prepare my changelog

Scenario: Display all commit messages of a repository
  Given a repository
  When ask for the changelog
  Then returns all commit messages
