module Fastlane
  module Actions
    module SharedValues
      UPDATE_CHANGELOG_CUSTOM_VALUE = :UPDATE_CHANGELOG_CUSTOM_VALUE
    end

    class UpdateChangelogAction < Action
      def self.run(params)
        release_name = params[:release_name]
        file_path = params[:file_path]

        unversioned_title = "## Unversioned"
        
        file = File.read(file_path)
        split_file = file.split(unversioned_title)
        if split_file.length == 2
          new_title = "#{unversioned_title}\n-\n\n"
          current_version = "## #{release_name}"

          new_content = new_title + current_version + split_file[1]
          File.write(file_path, new_content)
          UI.success "Version #{release_name} added to changelog successfully"
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This updates the changelog and changes the unreleased to the release name"
      end

      def self.details
        "This action renames the current \"Unreleased\" text to the release name provided. Then it creates another \"Unreleased\" title"
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :release_name,
                                       env_name: "FL_UPDATE_CHANGELOG_RELEASE_NAME", # The name of the environment variable
                                       description: "Release name to be used on the changelog", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No release name for UpdateChangelogAction given, pass using `release_name: 'name'`") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       env_name: "FL_UPDATE_CHANGELOG_FILE_PATH", # The name of the environment variable
                                       description: "File path of the changelog", # a short description of this parameter
                                       optional: true,
                                       default_value: "CHANGELOG.md")
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
