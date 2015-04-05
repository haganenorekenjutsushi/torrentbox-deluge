#
# Cookbook Name:: deluge
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Ensure we've got the latest repo
apt_repository 'deluge' do
  uri node['deluge']['repository']
end

# Install deluge & deluge-web
%w{deluged deluge-web}.each do |pkg|
	apt_package pkg do
		action :install
		retries 3
		retry_delay 10
	end
end

# Ensure we've got a service account
user node['deluge']['config']['user'] do
  supports :manage_home => true
  gid "users"
  home "/home/#{node['deluge']['config']['user']}"
  shell "/bin/bash"
  password node['deluge']['config']['password']
end

# Control the deluge daemon job file
template '/etc/init/deluged.conf'  do
	source 'deluged.conf.erb'
	variables({
		:user => node['deluge']['config']['user'],
	})
end

# Control the deluge web daemon job file
template '/etc/init/deluge-web.conf'  do
	source 'deluge-web.conf.erb'
	variables({
		:user => node['deluge']['config']['user'],
	})
	notifies :start, 'service[deluged]', :immediate
end

# Control the data dir
directory node['deluge']['config']['datadir'] do
  owner node['deluge']['config']['user']
  mode '0755'
  action :create
  recursive true
end

# Assume ownership of the contents of the data directory (useful when populating a backup in another recipe)
execute "own-datadir-deluge" do
  command <<-EOH    
  chown -R #{node['deluge']['config']['user']} #{node['deluge']['config']['datadir']}
  EOH
end

# Control the log dir
directory '/var/log/deluge' do
  owner node['deluge']['config']['user']
  mode '0750'
  action :create
end

# Stop the service
service 'deluged' do
	provider Chef::Provider::Service::Upstart
	action :stop
end

# Ensure the config directory exists
directory "/home/#{node['deluge']['config']['user']}/.config/deluge/" do
  owner node['deluge']['config']['user']
  mode '0750'
  recursive true
  action :create
end

# Control the core config file
template "/home/#{node['deluge']['config']['user']}/.config/deluge/core.conf"  do
	source 'core.conf.erb'
	variables({
		:move_completed_path => node['deluge']['config']['move_completed_path'],
		:torrentfiles_location => node['deluge']['config']['torrentfiles_location'],
		:download_location => node['deluge']['config']['download_location'],
		:plugins_location => node['deluge']['config']['plugins_location'],
		:autoadd_location => node['deluge']['config']['autoadd_location']
	})
end

# Control the web config file
template "/home/#{node['deluge']['config']['user']}/.config/deluge/web.conf"  do
	source 'web.conf.erb'
	variables({
		:web_port => node['deluge']['config']['web_port'],
		:web_password => "#{Digest::SHA1.hexdigest node['deluge']['config']['web_password_salt'] + node['deluge']['config']['web_password'] }",
		:web_password_salt => node['deluge']['config']['web_password_salt']
	})
end

# Stop the service
service 'deluged' do
	provider Chef::Provider::Service::Upstart
	action :start
end