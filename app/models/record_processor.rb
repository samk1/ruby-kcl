class RecordProcessor < Aws::KCLrb::V2::RecordProcessorBase
  # (see Aws::KCLrb::V2::RecordProcessorBase#init_processor)
  def init_processor(initialize_input)
    @shard_id = initialize_input.shard_id
    @checkpoint_freq_seconds = 10
  end

  # (see Aws::KCLrb::V2::RecordProcessorBase#process_records)
  def process_records(process_records_input)
    last_seq = nil
    records = process_records_input.records
    records.each do |record|
      data = Base64.decode64(record['data'])
      process_record(record, data)
      last_seq = record['sequenceNumber']
    end

    # Checking if last sequenceNumber is not nil and if it has been more than @check_freq_seconds before checkpointing.
    if last_seq &&
       (@last_checkpoint_time.nil? || ((DateTime.now - @last_checpoint_time) * 86_400 > @checkpoint_freq_seconds))
      checkpoint_helper(process_records_input.checkpointer, last_seq)
      @last_checpoint_time = DateTime.now
    end
  end

  # (see Aws::KCLrb::V2::RecordProcessorBase#lease_lost)
  def lease_lost(lease_lost_input)
    #   Lease was stolen by another Worker.
  end

  # (see Aws::KCLrb::V2::RecordProcessorBase#shard_ended)
  def shard_ended(shard_ended_input)
    checkpoint_helper(shard_ended_input.checkpointer)
  end

  # (see Aws::KCLrb::V2::RecordProcessorBase#shutdown_requested)
  def shutdown_requested(shutdown_requested_input)
    checkpoint_helper(shutdown_requested_input.checkpointer)
  end

  private

  # Helper method that retries checkpointing once.
  # @param checkpointer [Aws::KCLrb::Checkpointer] The checkpointer instance to use.
  # @param sequence_number (see Aws::KCLrb::Checkpointer#checkpoint)
  def checkpoint_helper(checkpointer, sequence_number = nil)
    checkpointer.checkpoint(sequence_number)
  rescue Aws::KCLrb::CheckpointError => e
    # Here, we simply retry once.
    # More sophisticated retry logic is recommended.
    checkpointer.checkpoint(sequence_number) if sequence_number
  end

  # Called for each record that is passed to record_processor.
  # @param record Kinesis record
  def process_record(record, data)
    length = if data.nil?
               0
             else
               data.length
             end
    Rails.logger.info(data.to_s)
    warn("ShardId: #{@shard_id}, Partition Key: #{record['partitionKey']}, Sequence Number:#{record['sequenceNumber']}, Length of data: #{length}")
  rescue StandardError => e
    warn "#{e}: Failed to process record '#{record}'"
  end
end
