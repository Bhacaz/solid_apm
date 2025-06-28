module SolidApm
  class Sampler
    def self.should_sample?
      sampling_rate = [1, SolidApm.transaction_sampling].max
      return true if sampling_rate == 1
      
      thread_counter = Thread.current[:solid_apm_counter] ||= 0
      Thread.current[:solid_apm_counter] = (thread_counter + 1) % sampling_rate

      Thread.current[:solid_apm_counter] == 0
    end
  end
end
