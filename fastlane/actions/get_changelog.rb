module Fastlane
  module Actions
    module SharedValues
      GET_CHANGELOG_CUSTOM_VALUE = :GET_CHANGELOG_CUSTOM_VALUE
    end

    class GetChangelogAction < Action
      def self.run(params)
        version = params[:version]
        file_path = params[:file_path]
        file = File.read(file_path)
        changes = file.split("## #{version}")[1].split("##")[0]
        return changes
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This gets the latest changes on the changelog"
      end

      def self.details
        "This action gets the latest changes on the changelog after the title."
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       env_name: "FL_GET_CHANGELOG_FILE_PATH", # The name of the environment variable
                                       description: "File path of the changelog", # a short description of this parameter
                                       optional: true,
                                       default_value: "CHANGELOG.md"),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_GET_CHANGELOG_VERSION", # The name of the environment variable
                                       description: "The version which the changelog will be returned", # a short description of this parameter
                                       optional: false)
        ]
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["douglas.iacovelli"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
