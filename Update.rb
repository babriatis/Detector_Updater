# Prints to the console the correct useage of the program
def show_usage
  puts 'Usage:'
  puts 'ruby Updater.rb *IPsAndPorts.txt* *Script.txt*'
  puts '*IPsAndPorts.txt* should already exist and be valid.'
  puts '*Script.txt* should already exist and be valid.'
end

ip_filename = ARGV[0]
script_filename = ARGV[1]
$ips_and_ports = []
$script_lines = []


# This method checks to see if the file exists.
# If it doesn't, it informs the user and prints
# out the correct usage.
def file_exists(ip_filename, script_filename)
  if ip_filename.nil?
    puts
    puts 'You haven\'t entered an IP filename.'
    puts
    show_usage
    false
  elsif script_filename.nil?
    puts
    puts 'You haven\'t entered a script filename.'
    puts
    show_usage
    false
  else

    # Checking and opening IP and Ports file
    begin
      File.open(ip_filename, 'r') do |f|
        f.each_line do |line|
          $ips_and_ports.push(line.strip.gsub(/\t/,' '))
        end
      end
    rescue Errno::ENOENT
      puts
      puts "Failed to open #{ip_filename}."
      puts
      show_usage
      false
    end

    # Checking and opening script txt file
    begin
      File.open(script_filename, 'r') do |f|
        f.each_line do |line|
          $script_lines.push(line.strip)
        end
      end
    rescue Errno::ENOENT
      puts
      puts "Failed to open #{script_filename}."
      puts
      show_usage
      false
    end
  end
end

if file_exists(ip_filename, script_filename)
  puts 'Updating...'
  i = 0

  #Prepends each individual IP and port to the begining of the script file
  $ips_and_ports.each do
    File.open("script_new.txt", 'w') do |f|
      f.puts $ips_and_ports[i]
      File.foreach(script_filename) do |line|
        f.puts line
      end
    end

    `TST10.exe /r:script_new.txt /o:Outputs/#{$ips_and_ports[i][/[^\s]+/]}.txt /m`

    # Checking file size to see if the updates were a success or failure
    if File.new("Outputs/#{$ips_and_ports[i][/[^\s]+/]}.txt").size > 1
      puts "IP Address: #{$ips_and_ports[i][/[^\s]+/]} SUCCESS"
    else
      puts "IP Address: #{$ips_and_ports[i][/[^\s]+/]} FAILED"
    end

    i+=1
  end
  File.delete("script_new.txt")
end
