# Feedlot - A Decentralized Price Feed Marketplace

After reading the TrustedFeeds.org idea, I wanted to prototype a feed marketplace design that is on-chain (and with a few modifications to the TrustedFeeds idea). Many of the contract specifications listed in the TrustedFeeds post are followed here, with the exception of a few.

Below is the project specifications. Everything is open-source and written in solidity. Feel free to do what ever you want with it. UI and a better/cleaner SOL code coming soon.
https://github.com/SilentCicero/Ethereum/tree/master/Feedlot

#The Concept
Feedlot is an on-chain decentralized price feed marketplace that enables feed buyers to find, check, review and establish connections with feed providers (sellers). Feed buyers can request price feeds and have providers, of their choosing, provide price feeds for their intended purpose.

#Play-By-Play
1. A feed buyer can request a price feed by submitting a request ticket (following a specific ticket protocol).
2. Feed providers can respond to feed requests and specify an amount for doing the job.
3. Feed buyers can overview their provider responses, human-verify and check the providers (via reviews, ratings) and decide which one they want to do business with.
4. Feed buyers then choose a provider, a receipt is created, the provider is notified (perhaps via whisper).
5. The selected feed provider now has access to the request, they create a feed, and assign that feed to the request ticket.
6. If the feed buyer likes the feed data, they can request feed data directly from the feed and the feed provider can request their money after a 24 hour period. If the buyer is unhappy with the feed, and it is within 24 hours of the receipt being created, the buyer can opt-out of the contract (by setting the provider to nothing).
**Given the buyer opts out within the 24 hour period: The feed provider can no longer claim their ether reward for setting up the feed.

#Price Feed Request Tickets
Request tickets are used to signal demand for a specific needed price feed.
The current requirements:
- [uint] Require a type (not yet defined), such as: 0 for sports, 1 for weather, 2 for stock
- [string32] A cron jobs layout (which is a string that follows the cron-jobs specification such as: "0,30 2 1,15 2 1").
- [uint] Timeout (when the provider no longer needs to provide the feed)
- [string32] Description such as: "Dow Jones Industrial Average Value"
** These ticket request parameters are subject to change.

#Reviews
- In order to leave a review/rating on a feed provider, feed buyers must have done business with the feed provider (i.e. have a receipt of their business dealings, and a receipt ID).
- The contract enforces this by checking receipt data.

#Receipts
- Receipts act as records of business dealings and can be used to prove some-kind of business dealings with feed providers.
- Receipts are created even if the buyer doesn't like the feed they get (so that they can leave reviews on that provider even if they refused a deal with that provider).

#Feeds
- Feeds are presently just data struct's, but could and most likely will be changed to actual contracts.
- The feed struct has a mapping data var (uint => uint) where feed data can be sent.
- Some data feeds may have a multitude of price data, so a mapping var can accommodate this for now.
- Feed data can be accessed, for free by the original buyer, or for a per-use price by other buyers.
- Feeds can be linked to multiple feed request tickets (thus a provider does not have to create the same feed twice).
- The provider should be able to allow themselves and a specified contract address to access the incoming feed data through the get function in this contract.

#Feed Providers
- Feed providers are required to register their name, company and website with a feed provider contract.
- Feed providers are responsible for doing their part in building a brand and a good reputation on the system.

#Prices and Fees
- In order to submit feed request tickets, a request fee will be required (to prevent spamming).
- In order to signup as a feed provider, a provider fee will be required (to mitigate bad providers).
- The fees are, at this time, being lorded (but this is not a requirement, merely a quality control measure to prevent mass spamming).
- Note: fees will definitely not ward off all bad spammers or providers, just mitigate some of them.

#On Web3ness and Storage Concerns
- Considering this may have considerable storage costs, this may not be an economically reasonable or viable option for a feed marketplace. I understand storing all this data on the chain (some of which is not really consensus or transaction oriented in nature) is potentially a web 3 problem.
- A good reputation system is still needed that will have to materialize with a community and a good UI (among many other effects i.e. the network effect).
- The benefits of doing this on-chain is that things like reviews and ratings can be traced back to business dealings (even though this can be cheated like most rating/rep systems), requests can be turned into feeds, the infrastructure does not rely on a central website location (even though one will be built and provided).
- The code is in it's early stages, so excuse the present lack of inheritance, use of good contract structure and mapping (instead of arrays).
- Concern: Feed data is being sent to one central contract, this may be a problem (a sort-of centralization within the decentralized blockchain). I don't know what the ramifications or significance that has on this idea.

I figure that, even though TrustedFeeds will probably happen and go live (hopefully at launch), many solutions should exist to get price feeds connected to the chain. This is one of many. A special thanks to Edwardh for coming up with and furthering the idea.

TrustedFeeds.org Forum Post:
https://forum.ethereum.org/discussion/874/trustedfeeds-org-call-for-participants/p1


Cheers,
SC
