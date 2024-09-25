# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}
# Set 'sources_1' fileset object
set obj [get_filesets sources_1]

set files [glob ${origin_dir}/../src/*.v]
add_files -norecurse -fileset $obj $files
set_property source_mgmt_mode All [current_project]
