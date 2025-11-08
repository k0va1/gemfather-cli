require_relative "cli/settings_builder"
require "fileutils"
require "erb"

module Gemfather
  module Cli
    class Error < StandardError; end

    class Runner
      attr_accessor :settings_builder, :settings

      def initialize(settings_builder: Gemfather::Cli::SettingsBuilder.new)
        @settings_builder = settings_builder
        @settings = @settings_builder.call
      end

      def call
        init_gem
        update_gem_info
        copy_templates
      end

      private

      def build_bundle_options
        linter_options = build_linter_options
        test_options = build_test_options
        ci_options = build_ci_options

        [
          linter_options,
          test_options,
          ci_options
        ].join(" ")
      end

      def build_linter_options
        case settings[:linter]
        when "rubocop"
          "--linter=rubocop"
        when "standard"
          "--linter=standard"
        else
          ""
        end
      end

      def build_test_options
        case settings[:test]
        when "minitest"
          "--test=minitest"
        when "rspec"
          "--test=rspec"
        else
          ""
        end
      end

      def build_ci_options
        settings[:ci] ? "--ci=#{settings[:ci]}" : ""
      end

      def init_gem
        bundle_options = build_bundle_options
        `bundle gem #{settings[:name]} #{bundle_options} > /dev/null 2>&1 && cd #{settings[:name]}`
      end

      def update_gem_info
        gemspec_path = File.join(Dir.pwd, settings[:name], "#{settings[:name]}.gemspec")
        updated_gemspec_lines = update_gemspec_lines(gemspec_path)

        File.write(gemspec_path, updated_gemspec_lines.join)
      end

      def update_gemspec_lines(gemspec_path)
        IO.readlines(gemspec_path).map do |line|
          case line
          when /spec\.summary =.*/
            line.gsub(/=\s".*"/, "= \"#{settings[:summary]}\"")
          when /spec\.description =.*/
            line.gsub(/=\s".*"/, "= \"#{settings[:description]}\"")
          when /spec\.homepage =.*/
            line.gsub(/=\s".*"/, "= \"#{settings[:homepage]}\"")
          when /spec\.metadata\["homepage_uri"\] =.*/
            line.gsub(/=\s".*"/, "= spec.homepage")
          when /spec\.metadata\["source_code_uri"\] =.*/
            line.gsub(/=\s".*"/, "= spec.homepage")
          when /spec\.metadata\["changelog_uri"\] =.*/
            if settings[:changelog?]
              line.gsub(/=\s".*"/, "= \"#{settings[:homepage]}/blob/master/CHANGELOG.md\"")
            end
          when /spec\.metadata\["allowed_push_host"\] =.*/
            next
          else
            line
          end
        end
      end

      def copy_templates
        copy_makefile
        copy_changelog
        copy_coc
        copy_release_please
        copy_ci_files
      end

      def copy_makefile
        return unless settings[:makefile?]

        rendered_string = render_erb("Makefile.erb", settings_builder.get_binding)
        File.write(File.join(new_gem_root, "Makefile"), rendered_string)
      end

      def copy_changelog
        return unless settings[:changelog?]

        FileUtils.cp(File.join(templates_root, "CHANGELOG.md"), new_gem_root)
      end

      def copy_coc
        return unless settings[:coc?]

        rendered_string = render_erb("CODE_OF_CONDUCT.md.erb", settings_builder.get_binding)
        File.write(File.join(new_gem_root, "CODE_OF_CONDUCT.md"), rendered_string)
      end

      def copy_release_please
        return unless settings[:use_release_please]

        rendered_string = render_erb("release-please-config.json.erb", settings_builder.get_binding)
        File.write(File.join(new_gem_root, "release-please-config.json"), rendered_string)
        FileUtils.cp(File.join(templates_root, ".release-please-manifest.json"), new_gem_root)

        if settings[:ci] == "github"
          FileUtils.cp(File.join(templates_root, "ci/github/release.yml"), File.join(new_gem_root, ".github/workflows/release.yml"))
        end
      end

      def copy_ci_files
        if settings[:ci] == "github"
          FileUtils.rm_rf(File.join(new_gem_root, ".github/workflows/main.yml"))
          FileUtils.cp(File.join(templates_root, "ci/github/ci.yml"), File.join(new_gem_root, ".github/workflows/ci.yml"))
        end
      end

      def new_gem_root
        @new_gem_root ||= File.join(Dir.pwd, settings[:name])
      end

      def templates_root
        @templates_root ||= File.join(File.dirname(__dir__), "../templates")
      end

      def render_erb(file, binding)
        template_path = File.join(templates_root, file)
        template = ERB.new(File.read(template_path))
        template.result(binding)
      end
    end
  end
end
