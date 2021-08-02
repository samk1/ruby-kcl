# Start the main processing loop
driver = Aws::KCLrb::KCLProcess.new(RecordProcessor.new)
driver.run
