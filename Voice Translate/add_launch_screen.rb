require 'xcodeproj'

project_path = 'Voice Translate.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'Voice Translate' }

# Path to the storyboard
storyboard_path = 'Voice Translate/LaunchScreen.storyboard'

# Add the file to the main group
group = project.main_group.find_subpath('Voice Translate', true)

# Check if file reference already exists
file_ref = group.files.find { |f| f.path == 'LaunchScreen.storyboard' }
if file_ref.nil?
  file_ref = group.new_file('LaunchScreen.storyboard')
end

# Add to the resources build phase if not already there
resources_phase = target.resources_build_phase
unless resources_phase.files.any? { |f| f.file_ref == file_ref }
  resources_phase.add_file_reference(file_ref)
end

# Update build settings
target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_KEY_UILaunchStoryboardName'] = 'LaunchScreen'
end

project.save
puts "Successfully added LaunchScreen.storyboard to project and updated build settings."
