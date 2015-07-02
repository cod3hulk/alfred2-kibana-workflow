#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "bundler/setup"
require "alfred"
require "elasticsearch"

Alfred.with_friendly_error do |alfred|
  # load configugration
  kibana_host = ENV['kibana_host']
  elastisearch_host = ENV['elasticsearch_host']

  fb = alfred.feedback

  # add default dashboard
  fb.add_item({
    :uid      => "",
    :title    => "default",
    :subtitle => "open default dashboard",
    :arg      => "#{kibana_host}/kibana/index.html#/dashboard/file/logstash.json",
    :valid    => "yes",
  })

  # retrieve dashboards from elasticsearch
  client = Elasticsearch::Client.new log: false, url: "#{elastisearch_host}"
  response = client.search index: 'kibana-int', type: 'dashboard', fields: 'title'
  dashboards = response['hits']['hits'].map {|elem| elem['_id']}

  # add dasboards retrieved from elasticsearch
  dashboards.each do |dashboard|
    fb.add_item({
      :uid      => "",
      :title    => "#{dashboard}",
      :subtitle => "open #{dashboard} dashboard",
      :arg      => "#{kibana_host}/kibana/index.html#/dashboard/elasticsearch/#{dashboard}",
      :valid    => "yes",
    })
  end

  puts fb.to_xml(ARGV)
end

