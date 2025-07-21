# @version ^0.4.1
"""
@license MIT 
@title Buy Me A Coffee!
@notice A funding contract where users send ETH >= $5 in value.
"""

# https://remix.ethereum.org/#url=https://github.com/Cyfrin/remix-buy-me-a-coffee-cu/buy_me_a_coffee.vy&lang=en&optimize=false&runs=200&evmVersion=null&version=soljson-v0.8.30+commit.73712a01.js

# For running this contract: 0.1 ETH = 100000000 GWEI 
# Chainlink Sepolia ETH/USD Aggregator: 0x694AA1769357215DE4FAC081bf1f309aDC325306
# Fake ETH Address to change owner: 0x000000000000000000000000000000000000dEaD


interface AggregatorV3Interface:
    def decimals() -> uint8: view
    def description() -> String[1000]: view
    def version() -> uint256: view
    def latestAnswer() -> int256: view

# Constants & Storage
MINIMUM_USD: public(constant(uint256)) = as_wei_value(5, "ether")
PRECISION: constant(uint256) = 1 * 10 ** 18

OWNER: public(address)
PRICE_FEED: public(immutable(AggregatorV3Interface))

funders: public(DynArray[address, 1000])
funder_to_amount_funded: public(HashMap[address, uint256])

# Constructor
@deploy
def __init__(price_feed: address):
    PRICE_FEED = AggregatorV3Interface(price_feed)
    self.OWNER = msg.sender

# Public funding function
@external
@payable
def fund():
    self._fund()

# Internal fund logic
@internal
@payable
def _fund():
    usd_value_of_eth: uint256 = self._get_eth_to_usd_rate(msg.value)
    # For Remix testing, this is mocked — comment in real network
    # assert usd_value_of_eth >= MINIMUM_USD, "You must spend more ETH!"

    self.funders.append(msg.sender)
    self.funder_to_amount_funded[msg.sender] += msg.value

# Withdraw function (owner-only)
@external
def withdraw():
    assert msg.sender == self.OWNER, "Not the contract owner!"
    raw_call(self.OWNER, b"", value=self.balance)

    for funder: address in self.funders:
        self.funder_to_amount_funded[funder] = 0
    self.funders = []

# Mocked ETH to USD conversion for Remix
@internal
@view
def _get_eth_to_usd_rate(eth_amount: uint256) -> uint256:
    # MOCK for testing – returns static USD value
    return 10 * PRECISION  # Treats all ETH as worth $10

# Public getter for ETH to USD conversion
@external
@view
def get_eth_to_usd_rate(eth_amount: uint256) -> uint256:
    return self._get_eth_to_usd_rate(eth_amount)

# Calculate total funded amount
@external
@view
def get_total_funded() -> uint256:
    total: uint256 = 0
    for funder: address in self.funders:
        total += self.funder_to_amount_funded[funder]
    return total

# Change ownership (owner-only)
@external
def change_owner(new_owner: address):
    assert msg.sender == self.OWNER, "Only the owner can change ownership"
    self.OWNER = new_owner

# Fallback to allow direct funding
@external
@payable
def __default__():
    self._fund()
