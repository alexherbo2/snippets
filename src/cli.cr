require "option_parser"
require "./snippets"
require "./env"

# Default input and output paths
SNIPPETS_CONFIG_PATH = Path[ENV["XDG_CONFIG_HOME"], "snippets"]
SNIPPETS_INPUT_PATHS = Snippets::Base.pathify(Dir.glob(SNIPPETS_CONFIG_PATH / "*"))
SNIPPETS_OUTPUT_PATH = Path[ENV["XDG_CACHE_HOME"], "snippets.json"]

module Snippets::CLI
  def self.start(argv)
    # Subcommand
    command = :help

    # Options
    watch = false

    # Option parser
    option_parser = OptionParser.new do |parser|
      parser.banner = "Usage: snippets <command> [arguments]"

      parser.on("build", "Build snippets") do
        command = :build

        parser.on("--watch", "Watch specified directories") do
          watch = true
        end
      end

      parser.on("get", "Get a property") do
        command = :get

        parser.on("input_paths", "Get input paths") do
          command = :get_input_paths
        end

        parser.on("output_path", "Get output path") do
          command = :get_output_path
        end

        parser.on("files", "Get snippet files") do
          command = :get_files
        end

        parser.on("all", "Get all snippets") do
          command = :get_all
        end

        parser.on("snippets", "Get snippets") do
          command = :get_snippets
        end

        parser.on("snippet", "Get a snippet") do
          command = :get_snippet
        end
      end

      parser.on("edit", "Edit snippets") do
        command = :edit
      end

      parser.on("help", "Show help") do
        command = :help
      end

      parser.invalid_option do |flag|
        STDERR.puts "Error: Unknown option: #{flag}"
        STDERR.puts parser
        exit(1)
      end
    end

    # Parse options
    option_parser.parse(argv)

    # Initialization
    snippets = Base.new(SNIPPETS_INPUT_PATHS, SNIPPETS_OUTPUT_PATH)

    # Commands ─────────────────────────────────────────────────────────────────

    case command

    # Build ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

    when :build
      # Input paths
      snippets.input_paths = argv unless argv.empty?

      puts snippets.build.to_json

      if watch
        snippets.watch do
          puts snippets.all.to_json
        end
      end

    # Get ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

    when :get
      puts option_parser.parse(["get", "--help"])

    when :get_input_paths
      puts snippets.input_paths.to_json

    when :get_output_path
      puts snippets.output_path.to_json

    when :get_files
      puts snippets.files.to_json

    when :get_all
      puts snippets.all.to_json

    when :get_snippets
      scope = argv

      puts snippets.get(scope).to_json

    when :get_snippet
      name = argv.pop
      scope = argv

      puts snippets.get(scope, name).to_json

    # Edit ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

    when :edit
      system(ENV["EDITOR"], Base.stringify(snippets.files))

    # Help ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

    when :help
      puts option_parser

    # Error ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

    else
      STDERR.puts option_parser
      exit(1)
    end
  end
end

Snippets::CLI.start(ARGV)
