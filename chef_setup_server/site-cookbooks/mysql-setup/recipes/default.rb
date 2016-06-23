#
# Cookbook Name:: mysql-setup
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
mysql_service 'foo' do
  port '3306'
  version '5.5'
  initial_root_password 'ilovessn777'
  action [:create, :start]
end