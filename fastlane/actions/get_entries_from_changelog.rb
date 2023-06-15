module Fastlane
  module Actions
    module SharedValues
      GET_ENTRIES_FROM_CHANGELOG_CUSTOM_VALUE = :GET_ENTRIES_FROM_CHANGELOG_CUSTOM_VALUE
    end

    class GetEntriesFromChangelogAction < Action
      def self.run(params)
        version_name = params[:version_name]
        file_path = params[:file_path]

        this_version_title = "## #{version_name}"

        file = File.read(file_path)
        split_file = file.split(this_version_title)
        if split_file.length == 2
          next_title_starter = '## '
          whole_text = split_file[1].split(next_title_starter)[0]
          entries = whole_text.strip().split(/\n+/)

          entries
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Gets the changelog entries from a given version name"
      end

      def self.details
        "This action finds a \"v[given-version-name]\" text occurrence on Changelog and returns the subsequent lines until the next version title"
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :version_name,
                                       env_name: "FL_GET_ENTRIES_FROM_CHANGELOG_VERSION_NAME", # The name of the environment variable
                                       description: "Release name to be used on the changelog", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No release name for GetEntriesFromChangelogAction given, pass using `version_name: 'x.x.x'`") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       env_name: "FL_GET_ENTRIES_FROM_CHANGELOG_FILE_PATH", # The name of the environment variable
                                       description: "File path of the changelog", # a short description of this parameter
                                       optional: true,
                                       default_value: "CHANGELOG.md")
        ]
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["sezabass"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
