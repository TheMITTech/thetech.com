require 'thread'

LOG_FILE = '/tmp/migrate_log'
SRC_BUCKET_NAME = 'thetech-staging-assets'
DST_BUCKET_NAME = 'thetech-staging-assets'

lines = File.read(LOG_FILE).lines.grep(/\[  MOVE FILE  \]/)

commands = lines.map do |l|
  from, to = l.split(']').last.split('=>').map(&:strip)
  "aws s3 cp --acl public-read 's3://#{SRC_BUCKET_NAME}#{from.gsub("'", "'\"'\"'")}' 's3://#{DST_BUCKET_NAME}#{to.gsub("'", "'\"'\"'")}'"
end
lock = Mutex.new

threads = (0...20).map do |id|
  Thread.new do
    while true
      lock.lock
      cmd = commands.pop
      lock.unlock
      break if cmd.nil?
      while !system(cmd) do; end
    end
  end
end

threads.map(&:join)
