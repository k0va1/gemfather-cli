require "tty-prompt"

module Gemfather
  module Cli
    class SettingsBuilder
      DEFAULT_GEM_NAME = "awesome-new-gem"
      DEFAULT_USER_EMAIL = "your-mail@example.com"
      DEFAULT_USERNAME = `whoami`.chomp

      attr_accessor :settings

      def initialize
        @settings = {}
      end

      def call
        prompt = TTY::Prompt.new(interrupt: :exit)

        user_email = `git config user.email`.chomp
        settings[:email] = user_email.empty? ? DEFAULT_USER_EMAIL : user_email

        username = `git config user.name`.chomp
        settings[:username] = username.empty? ? DEFAULT_USERNAME : username

        settings[:name] = prompt.ask("Gem name:", default: DEFAULT_GEM_NAME)
        settings[:summary] = prompt.ask("Summary", default: DEFAULT_GEM_NAME)
        settings[:description] = prompt.ask("Description", default: DEFAULT_GEM_NAME)
        settings[:homepage] = prompt.ask("Home page(URL)", default: DEFAULT_GEM_NAME, value: "https://github.com/")

        settings[:licence] = prompt.select("Select Licence") do |menu|
          menu.choice "MIT", "mit"
          menu.choice "N/A", "n/a"
        end

        settings[:linter] = prompt.select("Select linter") do |menu|
          menu.choice "Standard", "standard"
          menu.choice "Rubocop", "rubocop"
          menu.choice "N/A", "n/a"
        end

        settings[:test] = prompt.select("Select test tool") do |menu|
          menu.choice "RSpec", "rspec"
          menu.choice "Minitest", "minitest"
          menu.choice "N/A", "n/a"
        end

        settings[:ci] = prompt.select("Select CI") do |menu|
          menu.choice "GitHub", "github"
          menu.choice "Gitlab", "gitlab"
        end

        settings[:use_release_please] = prompt.yes?("Do you want to use release-please for releases?")

        settings[:makefile?] = prompt.yes?("Do you need Makefile?")
        settings[:coc?] = prompt.yes?("Do you need Code Of Conduct?")
        settings[:changelog?] = prompt.yes?("Do you need CHANGELOG file?")

        settings[:debugger] = prompt.select("Select debugger tool:") do |menu|
          menu.choice "IRB", "irb"
          menu.choice "Pry", "pry"
        end

        settings
      end

      def get_binding
        binding
      end
    end
  end
end
