# pragma version 0.4.1 
"""
@license MIT 
@title Buy Me A Coffee!
@author You!
@notice This contract is for creating a sample funding contract
"""

# For running this contract: 0.1 ETH = 100000000 GWEI 
# Chainlink Seplia ETH/UDS 0x694AA1769357215DE4FAC081bf1f309aDC325306

# We'll learn a new way to do interfaces later...
interface AggregatorV3Interface:
    def decimals() -> uint8: view
    def description() -> String[1000]: view
    def version() -> uint256: view
    def latestAnswer() -> int256: view

# Constants & Immutables
MINIMUM_USD: public(constant(uint256)) = as_wei_value(5, "ether")
PRICE_FEED: public(immutable(AggregatorV3Interface)) # 0x694AA1769357215DE4FAC081bf1f309aDC325306 sepolia 
OWNER: public(immutable(address))
PRECISION: constant(uint256) = 1 * (10 ** 18)

# Storage
funders: public(DynArray[address, 1000])
funder_to_amount_funded: public(HashMap[address, uint256])

# With constants: 262,853
@deploy
def __init__(price_feed: address):
    PRICE_FEED = AggregatorV3Interface(price_feed)
    OWNER = msg.sender

@external
@payable
def fund():
    self._fund()

@internal
@payable
def _fund():
    """Allows users to send $ to this contract
    Have a minimum $ amount to send

    How do we convert the ETH amount to dollars amount?
    """
    usd_value_of_eth: uint256 = self._get_eth_to_usd_rate(msg.value)
    # without sepolia, this doesn't work
    # assert usd_value_of_eth >= MINIMUM_USD, "You must spend more ETH!"
    self.funders.append(msg.sender)
    self.funder_to_amount_funded[msg.sender] += msg.value


@external
def withdraw():
    """Take the money out of the contract, that people sent via the fund function.

    How do we make sure only we can pull the money out?
    """
    assert msg.sender == OWNER, "Not the contract owner!"
    raw_call(OWNER, b"", value = self.balance)
    # send(OWNER, self.balance)
    # resetting
    for funder: address in self.funders:
        self.funder_to_amount_funded[funder] = 0
    self.funders = []

@internal
@view
def _get_eth_to_usd_rate(eth_amount: uint256) -> uint256:
    """
    Chris sent us 0.01 ETH for us to buy a coffee
    Is that more or less than $5?
    """
    # new
    # MOCK: Just return a fake USD value to bypass Chainlink for local testing
    return 10 * PRECISION  # Assume every ETH is worth $10

@external
@view
def get_total_funded() -> uint256:
    total: uint256 = 0
    for funder: address in self.funders:
        total += self.funder_to_amount_funded[funder]
    return total

@external 
@view 
def get_eth_to_usd_rate(eth_amount: uint256) -> uint256:
    return self._get_eth_to_usd_rate(eth_amount)

@external 
@payable 
def __default__():
    self._fund()

# @external 
# @view 
# def get_price() -> int256:
#     price_feed: AggregatorV3Interface = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
#     # ABI
#     # Addresss
#     return staticcall price_feed.latestAnswer()

# 4 / 2 = 2
# # 6 / 3 = 2
# # 7 / 3 = 2 (remove all decimals)
# @external 
# @view 
# def divide_me(number: uint256) -> uint256:
#     return number // 3