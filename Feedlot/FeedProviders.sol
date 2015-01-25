contract FeedProviders 
{
	struct Provider
	{
		string32 name;
		string32 url;
		string32 description;
	}
	
	mapping(string32 => address) name_to_provider;
	mapping(address => Provider) providers;
	
	function register(string32 name, string32 url, string32 description) 
	{
		Provider new_provider = providers[msg.sender];
		new_provider.name = name;
		new_provider.url = url;
		new_provider.description = description;
		
		address new_name_lookup = name_to_provider[name];
		new_name_lookup = msg.sender;
	}
	
	function unregister() 
	{
		Provider get_provider = providers[msg.sender];
		
		name_to_provider[get_provider.name] = address(0);
		
		get_provider.name = "";
		get_provider.url = "";
		get_provider.description = "";
	}
	
	function addressOf(string32 name) constant returns (address addr)
	{
	    address get_address = name_to_provider[name];
	    return get_address;
	}
	
	function nameOf(address addr) constant returns (string32 name) 
	{
		Provider get_provider = providers[addr];
		return get_provider.name;
	}
	
	function kill() 
	{
	   // TODO
	}
}
