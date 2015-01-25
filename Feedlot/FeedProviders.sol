contract FeedProviders 
{
	struct Provider
	{
		string32 name;
		string32 url;
		string32 description;
	}
	
	mapping(string32 => address) name_to_address;
	mapping(address => Provider) providers;
	
	function register(string32 name, string32 url, string32 description) 
	{
		Provider new_provider = providers[msg.sender];
		new_provider.name = name;
		new_provider.url = url;
		new_provider.description = description;
		address new_name_lookup = name_to_address[name];
		name_to_address[name] = msg.sender;
	}
	
	function unregister() 
	{
		Provider new_provider = providers[msg.sender];
		address new_name_lookup = name_to_address[new_provider.name];
		name_to_address[new_provider.name] = address(0);
		new_provider.name = '';
		new_provider.url = '';
		new_provider.description = '';
	}
	
	function addressOf(string32 name) constant returns (address addr)
	{
		address new_name_lookup = name_to_address[name];
		addr = new_name_lookup;
	}
	
	function nameOf(address addr) constant returns (string32 name) 
	{
		name = providers[addr].name;
	}
	
	function kill() 
	{
		// Todo
	}
}
