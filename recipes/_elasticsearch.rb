#
# Cookbook:: managed_automate
# Recipe:: _elasticsearch
#

elasticsearchconfig = Chef::Config[:file_cache_path] + '/elasticsearch_config.toml'

# turn off swap
# https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html#_swapping_is_the_death_of_performance
vm_swappiness = shell_out('sysctl -n vm.swappiness').stdout.strip.to_i
sysctl 'vm.swappiness' do
  value node['ma']['sysctl']['vm.swappiness']
  not_if { vm_swappiness <= 1 }
end

# assign heap size to 50% of available memory
total_mem = node['memory']['total'][0..-3].to_i
half_mem_megabytes = (total_mem / 1024) / 2

# Do not make your heap size > 32 GB.
# https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html#compressed_oops
# "If you want to play it safe, setting the heap to 31gb is likely safe."
half_mem_megabytes = 32600 if half_mem_megabytes > 32600

config = { 'elasticsearch.v1.sys.runtime': { 'heapsize': "#{half_mem_megabytes}m" } }

toml_file elasticsearchconfig do
  content config
end

execute "chef-automate config patch #{elasticsearchconfig}" do
  action :nothing
  subscribes :run, "toml_file[#{elasticsearchconfig}]", :immediately
end
