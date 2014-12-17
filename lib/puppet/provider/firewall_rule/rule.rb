require 'win32ole'
require 'digest/md5'

class Hash
  def rkey_count(search)
    i = 1
    search = Regexp.new(search.to_s) unless search.is_a?(Regexp)
    keys.each do |key|
      if key =~ search
       i += 1
      end
    end
    return i
  end
end

def attr_hash(rule)
  attr_hash = Hash.new()
  attr_hash['ensure'] = 'present'
  attr_hash['description'] = rule.description
  attr_hash['application_name'] = rule.applicationname
  attr_hash['service_name'] = rule.servicename
  attr_hash['protocol'] = rule.protocol
  attr_hash['local_ports'] = rule.localports
  attr_hash['remote_ports'] = rule.remoteports
  attr_hash['local_addresses'] = rule.localaddresses
  attr_hash['remote_addresses'] = rule.remoteaddresses
  attr_hash['icmp_types_and_codes'] = rule.icmptypesandcodes
  attr_hash['direction'] = rule.direction
  attr_hash['interfaces'] = rule.interfaces
  attr_hash['interface_types'] = rule.interfacetypes
  attr_hash['enabled'] = rule.enabled
  attr_hash['grouping'] = rule.grouping
  attr_hash['profiles'] = rule.profiles
  attr_hash['edge_traversal'] = rule.edgetraversal
  attr_hash['action'] = rule.action
  attr_hash['edge_traversal_options'] = rule.edgetraversaloptions
  
  return attr_hash
end

def system_rule_md5
  rules = WIN32OLE.new("HNetCfg.FwPolicy2").rules
  rule_hash = Hash.new()

  rules.each do |rule|
    if rule.enabled == true
      if rule_hash.has_key?(rule.name)
        rule_hash["#{rule.name} #{rule_hash.rkey_count(/^#{rule.name}.*$/i)}"] = attr_hash(rule)
      else
        rule_hash[rule.name] = attr_hash(rule)
      end
    end
  end
  Digest::MD5.hexdigest Marshal.dump(rule_hash.sort.to_s)
end

Puppet::Type.type(:firewall_rule).provide(:rule) do
  desc "Configures rules"

  def rule_hash
    #File.open(File.join('C:\\', 'system_rules.txt'), 'w') {|f| f.write(system_rule_hash(nil)) }
    #File.open(File.join('C:\\', 'json_rules.txt'), 'w') {|f| f.write(@resource.should(:rule_hash)) }
    #@resource.should(:rule_hash)
	system_rule_md5
  end
  
  def rule_hash=(value)
    puts 'change!'
  end
end