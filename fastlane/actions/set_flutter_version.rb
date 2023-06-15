module Fastlane
  module Actions
    module SharedValues
      SET_FLUTTER_VERSION_CUSTOM_VALUE = :SET_FLUTTER_VERSION_CUSTOM_VALUE
    end

    class SetFlutterVersionAction < Action
      def self.run(params)
        version_name = params[:version_name]

        current_version_regex = /^version:.+$/

        file_path = './pubspec.yaml'
        file = File.read(file_path)

        split_file = file.split(current_version_regex)
        if split_file.length == 2
          version_line = "version: " + version_name + "\n"
          new_content = split_file[0] + version_line + split_file[1]
          File.write(file_path, new_content)
          UI.success "Version #{version_name} set on pubspec.yaml successfully"
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This updates the version name on project's pubspec.yaml"
      end

      def self.details
        "This action searches for the current version name and replaces it with the one passed as a parameter."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version_name,
                                       env_name: "FL_SET_FLUTTER_VERSION_NAME", # The name of the environment variable
                                       description: "Version name to be set on pubspec.yaml", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No release name for SetFlutterVersionAction given, pass using `version_name: 'name'`") unless (value and not value.empty?)
                                       end)
        ]
      end

      def self.authors
        ["sezabass"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
