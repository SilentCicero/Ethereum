contract Config {
	function register(uint id, address service) {}
	function unregister(uint id) {}
	function lookup(uint service) constant returns(address a) {}
	function kill() {}
}

contract FeedProviders {
	function register(string32 name, string32 url, string32 description) {}
	function unregister() {}
	function addressOf(string32 name) constant returns (address addr) {}
	function nameOf(address addr) constant returns (string32 name) {}
	function kill() {}
}

contract Feedlot
{
    struct Feed
    {
        uint last_updated;
        address provider;
        string32 description;
        uint per_hit_price;
        mapping(uint => uint) data;
    }
    
    struct Receipt
    {
        address buyer;
        address provider;
        uint created;
        uint price;
    }
    
    struct Response
    {
        address provider;
        uint price;
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
        uint feed_id;
        uint receipt_id;
        uint num_responses;
    }
    
    struct Review
    {
        address from;
        address provider;
        uint rating;
        string32 short_review;
    }
    
    uint feed_request_price;
    uint feed_price;
    uint objection_timeframe;
    uint num_requests;
    uint num_receipts;
    uint num_feeds;
    uint num_reviews;
    uint num_responses;
    address ProvidersAddress;
    address owner; // Contract Owner
    
    mapping(uint => FeedRequest) requests; // Price Feed Requests
    mapping(uint => Receipt) receipts; // Transaction Receipts (proof of interaciton)
    mapping(uint => Feed) feeds; // Price Feeds
    mapping(uint => Review) reviews; // Provider Reviews
    mapping(uint => mapping(uint => Response)) responses; // Request Responses
    
    function Feedlot()
    {
        num_requests = 0;
        feed_price = 1000; // 1000 Wie Price to Setup Feed
        feed_request_price = 1000; // 1000 Wei Priceto Request Feed
        objection_timeframe = 86400; // 1 Day Objection Period
        owner = 0xc7e14ab7e82b94b7aeacb36150720a5646732c69;
        ProvidersAddress = 0xdf8bbe8536ce8ce569ff53f18355f6356d99e6e1;
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
    
    // Review Provider
    // ** Only feed buyers can review providers they have had 
    // dealings with.
    // Buyers should keep their receipts, just in case they want
    // to review a provider later on.
    function review_provider(uint receipt_id, uint rating
    , string32 short_review)
    {
        Receipt get_receipt = receipts[receipt_id];
        
        if(get_receipt.buyer == msg.sender)
        {
            num_reviews++;
            Review new_review = reviews[num_reviews];
            new_review.provider = get_receipt.provider;
            new_review.rating = rating;
            new_review.short_review = short_review;
        }
    }
    
    // Setup a new feed
    function setup_feed(string32 description, uint per_hit_price) returns (uint feed_id)
    {
        if(msg.value > feed_price)
        {
            if(FeedProviders(ProvidersAddress).nameOf(msg.sender) != "")
            {
                num_feeds += 1;
                Feed new_feed = feeds[num_feeds];
                
                new_feed.provider = msg.sender;
                new_feed.description = description;
                new_feed.per_hit_price = per_hit_price;
                feed_id = num_feeds;
            }
        }
    }
    
    // Get Feed Data *that you paid for.
    function get_feed_data(uint request_id, uint data_key) returns (uint retVal)
    {
        FeedRequest get_request = requests[request_id];
        Feed get_feed = feeds[get_request.feed_id];
        
        if(get_request.from == msg.sender || msg.value > get_feed.per_hit_price)
        {
            retVal = get_feed.data[data_key];
        }
    }
    
    // Destroy Feed
    // Only the Feed Provider can Destory Their own Feeds.
    function destory_feed(uint feed_id)
    {
        Feed get_feed = feeds[feed_id];
        
        if(get_feed.provider == msg.sender)
        {
            get_feed.description = "";
            get_feed.last_updated = 0;
            get_feed.per_hit_price = 0;
            //delete get_feed.data;
        }
    }
    
    // Claim Feed Reward.
    // Allow feed provider to claim reward for building a good feed.
    function claim_reward(uint request_id)
    {
        FeedRequest get_request = requests[request_id];
        if(get_request.provider == msg.sender)
        {
            Receipt new_receipt = receipts[get_request.receipt_id];
            
            if(new_receipt.provider == msg.sender 
            && (new_receipt.created + objection_timeframe > block.timestamp))
            {
                get_request.provider.send(new_receipt.price);
            }
        }
    }
    
    // Select provider for Feed request.
    // Must pay the chosen amount in the response.
    function select_provider(uint request_id, uint provider_response_id)
    {
        FeedRequest get_request = requests[request_id];
        if(get_request.from == msg.sender)
        {
            Response get_response = responses[request_id][provider_response_id];
        
            if(get_response.provider != address(0))
            {
                if(msg.value >= get_response.price)
                {
                    get_request.provider = get_response.provider;
                    
                    num_receipts++;
                    Receipt new_receipt = receipts[num_receipts];
                    new_receipt.buyer = msg.sender;
                    new_receipt.provider = get_response.provider;
                    new_receipt.price = get_response.price;
                    new_receipt.created = block.timestamp;
                    get_request.receipt_id = num_receipts;
                }
            }
        }
    }
    
    // Respond to Feed request
    // Once the Provider Responds, they will have to watch for a response
    // from the feed buyer.
    // Althought the feed provider could be alerted via whisper.
    function respond(uint request_id, uint price)
    {
        if(FeedProviders(ProvidersAddress).nameOf(msg.sender) != "")
        {
            FeedRequest get_request = requests[request_id];
            if(get_request.from != address(0))
            {
                num_responses += 1;
                get_request.num_responses += 1;
                Response new_response = responses[request_id][num_responses];
                
                new_response.price = price;
                new_response.provider = msg.sender;
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
    
    // Get a Particular Response
    function get_response(uint request_id
    , uint response_id) returns (Response retVal)
    {
        FeedRequest get_request = requests[request_id];
        
        if(msg.sender == get_request.from)
        {
            retVal = responses[response_id][response_id];
        }
    }
    
    // Request a New Price Feed
    function request_feed(uint8 type, string32 cron
    , uint timeout, string32 description) returns (uint request_id)
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
        The provider may continue to use the feed.
        In that case buyers could extend their contract.
        
        DESCRIPTION
        The description of the feed you want, for example
        , Dow Jones Industrial Average Value.
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
            request_id = id;
        }
    }
    
    // Get Number of Price Feed Requests
    function get_num_requests() returns (uint retVal)
    {
        retVal = num_requests;
    }
    
    // Get Request Data
    function get_request(uint request_id) returns (FeedRequest retVal)
    {
        retVal = requests[request_id];
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
