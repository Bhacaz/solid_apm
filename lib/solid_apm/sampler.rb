module SolidApm
  class Sampler
    def self.should_sample?
      return true if SolidApm.transaction_sampling <= 1

      thread_counter = Thread.current[:solid_apm_counter] ||= 0
      Thread.current[:solid_apm_counter] = (thread_counter + 1) % SolidApm.transaction_sampling

      Thread.current[:solid_apm_counter] == 0
    end
  end
end
