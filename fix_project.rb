require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'Runner' }

if target.nil?
  puts "Runner target not found!"
  exit 1
end

# Find the group that contains ExerciseAnalyzerFactory.swift
file_ref = project.files.find { |f| f.path == 'ExerciseAnalyzerFactory.swift' || f.name == 'ExerciseAnalyzerFactory.swift' }

if file_ref
  group = file_ref.parent
  puts "Found group: #{group.name || group.path}"
else
  # Fallback to Runner group
  runner_group = project.main_group.children.find { |g| g.name == 'Runner' || g.path == 'Runner' }
  group = runner_group.new_group('ExerciseCoaching')
  puts "Created/Fallback to group: ExerciseCoaching"
end

files_to_add = [
  'SquatAnalyzer.swift',
  'ShoulderStretchAnalyzer.swift'
]

files_to_add.each do |file_name|
  # Avoid duplicates
  existing_ref = group.files.find { |f| f.path == file_name || f.name == file_name }
  if existing_ref
    puts "#{file_name} already exists in project."
  else
    new_file_ref = group.new_file(file_name)
    target.source_build_phase.add_file_reference(new_file_ref)
    puts "Added #{file_name} to project and build phase."
  end
end

project.save
puts "Project saved successfully."
