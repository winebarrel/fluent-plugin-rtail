describe Fluent::RtailOutput do
  let(:time) do
    Time.parse('2015-09-01 01:23:45 UTC').to_i
  end

  let(:driver) do
    Fluent::Test::Driver::Output.new(described_class).configure(fluentd_conf)
  end

  let(:log) do
    driver.instance.log
  end

  context 'when send message' do
    let(:fluentd_conf) do
      <<-EOS
        @type rtail
      EOS
    end

    specify do
      %w(
        {"id":"foo","timestamp":1441070625000,"content":"zoo"}
        {"id":"bar","timestamp":1441070625000,"content":"100"}
      ).each do |message|
        expect_any_instance_of(UDPSocket).to receive(:send).with(message, 0)
      end

      driver.run(default_tag: 'test', flush: true, shutdown: true) do
        driver.feed(time, {'id' => 'foo', 'content' => 'zoo'})
        driver.feed(time, {'id' => 'bar', 'content' => 100})
      end
    end
  end

  context 'when send message (specify key)' do
    let(:fluentd_conf) do
      <<-EOS
        @type rtail
        id_key id2
        content_key content2
      EOS
    end

    specify do
      %w(
        {"id":"foo","timestamp":1441070625000,"content":"zoo"}
        {"id":"bar","timestamp":1441070625000,"content":"100"}
      ).each do |message|
        expect_any_instance_of(UDPSocket).to receive(:send).with(message, 0)
      end

      driver.run(default_tag: 'test', flush: true, shutdown: true) do
        driver.feed(time, {'id2' => 'foo', 'content2' => 'zoo'})
        driver.feed(time, {'id2' => 'bar', 'content2' => 100})
      end
    end
  end

  context 'without id key' do
    let(:fluentd_conf) do
      <<-EOS
        @type rtail
      EOS
    end

    specify do
      %w(
        {"id":"bar","timestamp":1441070625000,"content":"100"}
      ).each do |message|
        expect_any_instance_of(UDPSocket).to receive(:send).with(message, 0)
      end

      expect(log).to receive(:warn).with(
        %!'id' key does not exist: ["test", 1441070625, {"xid"=>"foo", "content"=>"zoo"}]!)

      driver.run(default_tag: 'test', flush: true, shutdown: true) do
        driver.feed(time, {'xid' => 'foo', 'content' => 'zoo'})
        driver.feed(time, {'id' => 'bar', 'content' => 100})
      end
    end
  end

  context 'without content key' do
    let(:fluentd_conf) do
      <<-EOS
        @type rtail
      EOS
    end

    specify do
      %w(
        {"id":"bar","timestamp":1441070625000,"content":"100"}
      ).each do |message|
        expect_any_instance_of(UDPSocket).to receive(:send).with(message, 0)
      end

      expect(log).to receive(:warn).with(
        %!'content' key does not exist: ["test", 1441070625, {"id"=>"foo", "xcontent"=>"zoo"}]!)

      driver.run(default_tag: 'test', flush: true, shutdown: true) do
        driver.feed(time, {'id' => 'foo', 'xcontent' => 'zoo'})
        driver.feed(time, {'id' => 'bar', 'content' => 100})
      end
    end
  end

  context 'when use tag as id' do
    let(:fluentd_conf) do
      <<-EOS
        @type rtail
        use_tag_as_id true
      EOS
    end

    specify do
      %w(
        {"id":"test","timestamp":1441070625000,"content":"zoo"}
        {"id":"test","timestamp":1441070625000,"content":"100"}
      ).each do |message|
        expect_any_instance_of(UDPSocket).to receive(:send).with(message, 0)
      end

      driver.run(default_tag: 'test', flush: true, shutdown: true) do
        driver.feed(time, {'id' => 'foo', 'content' => 'zoo'})
        driver.feed(time, {'id' => 'bar', 'content' => 100})
      end
    end
  end

  context 'when use record as content' do
    let(:fluentd_conf) do
      <<-EOS
        @type rtail
        use_record_as_content true
      EOS
    end

    specify do
      %w(
        {"id":"foo","timestamp":1441070625000,"content":{"id":"foo","content":"zoo"}}
        {"id":"bar","timestamp":1441070625000,"content":{"id":"bar","content":100}}
      ).each do |message|
        expect_any_instance_of(UDPSocket).to receive(:send).with(message, 0)
      end

      driver.run(default_tag: 'test', flush: true, shutdown: true) do
        driver.feed(time, {'id' => 'foo', 'content' => 'zoo'})
        driver.feed(time, {'id' => 'bar', 'content' => 100})
      end
    end
  end
end
