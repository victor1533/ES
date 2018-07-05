require "github_api"
require 'github_api/v4/client'

class Repository
  attr_accessor :id, :url, :name, :labels, :languages, :commits, :created_at


  def clone(path)

  end
  def self.find(name)
    clientv4 = GithubApi::V4::Client.new("da970211782a4c010612c7b60da192c7fe6b154a")
    query = '{
            repository(owner: "' + name.split("/")[0] +'", name: "' + name.split("/")[1] +'") {
              id
              url
          		nameWithOwner
              createdAt
              languages(last:100){
                nodes{
                  name
                }
              }
            }
          }'.chomp

    r = clientv4.graphql(query: query)['data']['repository']

    if r.nil?
      nil
    else
      repository = Repository.new
      repository.name = name.split("/")[1]
      repository.owner = name.split("/")[0]
      repository.id = r["id"]
      repository.url = r["url"]
      repository.created_at = r["createdAt"]
    end

    query = '{
            repository(owner: "codetriage", name: "codetriage") {
              id
              url
          		nameWithOwner
              createdAt
              languages(last:100){
                nodes{
                  name
                }
              }
            }
          }'.chomp

      r = clientv4.graphql(query: query)['data']['repository']
       r["ref"]["target"]["edges"].each do |node|
         node = node["node"]
         commit = Commit.new
         commit.author = node["author"]["name"]
         commit.id = node["id"]
         commit.oid = node["oid"]
         commit.message_headline = node["messageHeadline"]
         commit.pushed_date  = node["pushedDate"]
         commit.commited_date = node["commitedDate"]

       end
      if r.nil?
        nil
      else
        while r["ref"]["target"]["history"]["pageInfo"]["hasNextPage"]
          endCursor = r["ref"]["target"]["history"]["pageInfo"]["endCursor"]
          query = '{
                  repository(owner: "codetriage", name: "codetriage") {
                    id
                    url
                    nameWithOwner
                    createdAt
                    languages(last:100){
                      nodes{
                        name
                      }
                    }
                  }
                }'.chomp

            r = clientv4.graphql(query: query)['data']['repository']
        end
      end

  end
end
