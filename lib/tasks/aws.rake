require 'json'

INSTANCE_KEYS = {
  "Staging" => 'tech-staging',
  "Staging Importer" => 'tech-staging',
  "Production Frontend" => 'tech-production',
  "Production Backend" => 'tech-production',
  "Production Importer" => 'tech-production',
}

INSTANCE_GROUPS = {
  "Staging" => 'staging',
  "Staging Importer" => 'staging',
  "Production Frontend" => 'production',
  "Production Backend" => 'production',
  "Production Importer" => 'production',
}

INSTANCE_SIZES = {
  "Staging" => 't2.micro',
  "Staging Importer" => 't2.micro',
  "Production Frontend" => 't2.medium',
  "Production Backend" => 't2.micro',
  "Production Importer" => 't2.medium',
}

INSTANCE_AMI_FILTERS = {
  "Staging" => 'Staging',
  "Staging Importer" => 'Staging',
  "Production Frontend" => 'Production Frontend',
  "Production Backend" => 'Production Backend',
  "Production Importer" => 'Production Backend',
}

namespace :aws do
  namespace :ami do
    task :list, [:filter] => [:environment] do |t, args|
      result = JSON.parse(`aws ec2 describe-images --owners self`)

      result['Images'].each do |a|
        if args[:filter].nil? || a['Name'] =~ /#{args[:filter]}/
          puts a['ImageId'] + " " + a['Name']
        end
      end
    end

    task backup_status: :environment do
      filters = INSTANCE_AMI_FILTERS.values.uniq

      filters.each do |f|
        amis = JSON.parse(`aws ec2 describe-images --owners self`)['Images'].select { |p| p['Name'].include?(f) }
        ami = amis.sort { |a, b| b['CreationDate'] <=> a['CreationDate'] }.first

        puts "#{f}: #{ami['CreationDate']}"
      end
    end

    def find_instance(filter)
      result = JSON.parse(`aws ec2 describe-instances`)
      result['Reservations'].each do |r|
        r['Instances'].each do |i|
          next unless i['State']['Name'] == 'running'
          amifilter = i['Tags'].select { |t| t['Key'] == 'AMIFilter' }.first['Value']
          next unless amifilter == filter
          return "#{i['InstanceId']}"
        end
      end
    end

    task :backup, [:filter] => [:environment] do |t, args|
      filters = INSTANCE_AMI_FILTERS.values.uniq
      unless filters.include?(args[:filter])
        puts 'Invalid type'
        return
      end

      i = find_instance(args[:filter])
      command = "aws ec2 create-image --instance-id #{i} --name \"#{args[:filter]} #{Time.now.strftime('%Y%m%d%H%M%S')}\""
      `#{command}`
    end
  end

  namespace :ec2 do
    task :launch, [:type] do |t, args|
      unless INSTANCE_KEYS.keys.include?(args[:type])
        puts 'Invalid type ' + args[:type]
        return
      end

      amis = JSON.parse(`aws ec2 describe-images --owners self`)['Images'].select { |p| p['Name'].include?(INSTANCE_AMI_FILTERS[args[:type]]) }
      ami = amis.sort { |a, b| b['CreationDate'] <=> a['CreationDate'] }.first

      name = "#{args[:type]} #{Time.now.strftime('%Y%m%d%H%M%S')}"

      command = "aws ec2 run-instances --image-id #{ami['ImageId']} --security-groups #{INSTANCE_GROUPS[args[:type]]} --instance-type #{INSTANCE_SIZES[args[:type]]} --placement AvailabilityZone=us-east-1b --key-name #{INSTANCE_KEYS[args[:type]]}"

      puts 'Launching'
      result = JSON.parse(`#{command}`)
      id = result['Instances'][0]['InstanceId']

      puts 'Waiting for 2 seconds'
      sleep 2

      puts 'Attaching tags'
      command = "aws ec2 create-tags --resources #{id} --tag \"Key=Name,Value=#{name}\""
      `#{command}`
      command = "aws ec2 create-tags --resources #{id} --tag \"Key=AMIFilter,Value=#{INSTANCE_AMI_FILTERS[args[:type]]}\""
      `#{command}`
      command = "aws ec2 create-tags --resources #{id} --tag \"Key=Role,Value=#{args[:type]}\""
      `#{command}`

      puts 'Waiting for 5 seconds'
      sleep 5

      puts 'Retrieving public IP address'
      command = "aws ec2 describe-instances --instance-ids #{id}"
      result = JSON.parse(`#{command}`)

      ip = result['Reservations'][0]['Instances'][0]['PublicIpAddress']
      puts ip
    end

    task list: :environment do
      result = JSON.parse(`aws ec2 describe-instances`)
      result['Reservations'].each do |r|
        r['Instances'].each do |i|
          next if i['State']['Name'] == 'terminated'
          name = i['Tags'].select { |t| t['Key'] == 'Name' }.first['Value']
          puts "[#{i['PublicIpAddress']}] #{name}: #{i['State']['Name']}"
        end
      end
    end

    def aws_ip(type)
      result = JSON.parse(`aws ec2 describe-instances`)
      result['Reservations'].each do |r|
        r['Instances'].each do |i|
          next unless i['State']['Name'] == 'running'
          name = i['Tags'].select { |t| t['Key'] == 'Name' }.first['Value']
          next unless name =~ /#{type} [0-9]{14}/
          return "#{i['PublicIpAddress']}"
        end
      end
    end

    task :ip, [:type] => [:environment] do |t, args|
      puts aws_ip(args[:type])
    end

    task export_ips: :environment do
      puts 'export STAGING_IP="' + aws_ip('Staging') + '"'
      puts 'export PRODUCTION_FRONTEND_IP="' + aws_ip('Production Frontend') + '"'
      puts 'export PRODUCTION_BACKEND_IP="' + aws_ip('Production Backend') + '"'
      puts 'export STAGING_IMPORTER_IP="' + aws_ip('Staging Importer') + '"'
    end
  end
end
