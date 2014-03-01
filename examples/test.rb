puts "foo"
puts "bar"
puts "baz"
$stdout.flush
sleep 1
puts "almost done"
raise 'xx'
