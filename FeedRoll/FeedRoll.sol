contract Config {
	function register(uint id, address service) {}
	function unregister(uint id) {}
	function lookup(uint service) constant returns(address a) {}
	function kill() {}
}

contract FeedProviders {
	function register(string32 name, string32 url, string32 description) {}
	function unregister() {}
	function rate() {}
	function addressOf(string32 name) constant returns (address addr) {}
	function nameOf(address addr) constant returns (string32 name) {}
	function kill() {}
}

contract FeedRoll
{
    struct Feed
    {
        uint last_updated;
        address provider;
        string32 description;
        uint price;
        mapping(uint => uint) data;
    }
    
    struct FeedRequest
    {
        uint type;
        uint timeout;
        string32 cron;
        string32 description;
        address from;
        address delivery_address;
        address provider;
        uint created;
        uint num_responses;
        uint feed_id;
        mapping(uint => address) responses;
    }
    
    uint feed_request_price;
    uint feed_price;
    uint objection_timeframe;
    uint num_requests;
    uint num_feeds;
    address ProvidersAddress;
    address owner;
    mapping(uint => FeedRequest) requests;
    mapping(uint => Feed) feeds;
    
    function FeedRoll()
    {
        num_requests = 0;
        feed_price = 1000; // 1000 Wie Price to Setup Feed
        feed_request_price = 1000; // 1000 Wei Priceto Request Feed
        objection_timeframe = 86400; // 1 Day Objection Period
        owner = 0xdf494886e70b06e474c3fbfffe2f23123;
        ProvidersAddress = 0xd5f9d8d94886e70b06e474c3fb14fd43e2f23970;
    }
    
    // Allow Feed provider to connect feed to feed request.
    function connect_feed(uint request_id, uint feed_id)
    {
        FeedRequest get_request = requests[request_id];
        
        if(get_request.provider == msg.sender)
        {
            Feed get_feed = feeds[feed_id];
            
            if(get_feed.provider == msg.sender)
            {
                get_request.feed_id = feed_id;
            }
        }
    }
    
    // Setup a new feed
    function setup_feed(string32 description) returns (uint feed_id)
    {
        if(msg.value > feed_price)
        {
            if(FeedProviders(ProvidersAddress).nameOf(msg.sender) != "")
            {
                num_feeds += 1;
                Feed new_feed = feeds[num_feeds];
                
                new_feed.provider = msg.sender;
                new_feed.description = description;
                feed_id = num_feeds;
            }
        }
    }
    
    // Get Feed Data *that you paid for.
    function get_feed_data(uint request_id, uint data_key) returns (uint retVal)
    {
        FeedRequest get_request = requests[request_id];
        Feed get_feed = feeds[get_request.feed_id];
        
        if(get_request.from == msg.sender || msg.value > get_feed.price)
        {
            retVal = get_feed.data[data_key];
        }
    }
    
    // Destroy Feed
    function destory_feed(uint feed_id)
    {
        Feed get_feed = feeds[feed_id];
        
        if(get_feed.provider == msg.sender)
        {
            get_feed.description = "";
            get_feed.last_updated = 0;
            get_feed.price = 0;
            //delete get_feed.data;
        }
    }
    
    // Select provider for Feed request.
    function select_provider(uint request_id, uint provider_response_id)
    {
        FeedRequest get_request = requests[request_id];
        if(get_request.from == msg.sender)
        {
            address provider = get_request.responses[provider_response_id];
        
            if(provider != address(0))
            {
                get_request.provider = provider;
            }
        }
    }
    
    // Respond to Feed request
    function respond(uint request_id)
    {
        if(FeedProviders(ProvidersAddress).nameOf(msg.sender) != "")
        {
            FeedRequest get_request = requests[request_id];
            if(get_request.from != address(0))
            {
                get_request.num_responses += 1;
                get_request.responses[get_request.num_responses] = msg.sender;
            }
        }
    }
    
    // Check to see if New Responses from Feed Providers
    function check_responses(uint request_id) returns (uint retVal)
    {
        FeedRequest get_request = requests[request_id];
        
        if(msg.sender == get_request.from)
        {
            retVal = get_request.num_responses;
        }
    }
    
    // Request a New Feed
    function request_feed(uint8 type, string32 cron, uint timeout, string32 description
    , address delivery_address)
    {
        /*
        TYPE
        0 Sports
        1 Weather
        2 Real Estate
        3 Stock
        4 Commodity
        5 Currency
        6 Market
        
        CRON
        **Follows the cronjobs scheme
        Minute, Hour, Day, Month, Weekday
        
        Such as: 0,30  2  1,15  2  1
        
        TIMEOUT
        The timestamp of when the contract should end.
        
        DESCRIPTION
        The description of the feed you want, for example
        , Dow Jones Industrial Average Value.
        
        DELIVERY ADDRESS
        The address you want the contract delivered too.
        */
        
        if(msg.value > feed_request_price)
        {
            uint id = num_requests++;
            FeedRequest new_request = requests[id];
            new_request.num_responses = 0;
            new_request.from = msg.sender;
            new_request.created = block.timestamp;
            new_request.type = type;
            new_request.cron = cron;
            new_request.timeout = timeout;
            new_request.description = description;
            new_request.delivery_address = delivery_address;
        }
    }
    
    // Set Global Request Price (too prevent spam)
    function set_price(uint new_request_price)
    {
        if(msg.sender == owner)
        {
            feed_request_price = new_request_price;
        }
    }
    
    // Set Global Objection Timeframe (24 hours)
    function set_objection_timeframe(uint new_objection_timeframe)
    {
        if(msg.sender == owner)
        {
            objection_timeframe = new_objection_timeframe;
        }
    }
}