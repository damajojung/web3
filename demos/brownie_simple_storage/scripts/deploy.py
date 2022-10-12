from brownie import accounts, config, SimpleStorage

from brownie.network import gas_price
from brownie.network.gas.strategies import LinearScalingStrategy

gas_strategy = LinearScalingStrategy("60 gwei", "70 gwei", 1.1)

gas_price(gas_strategy)


def deploy_simple_storage():
    # account = accounts[0]  If we want to use our local network with ganache

    # with brownie
    # account = accounts.load("freecodecamp-account")
    # print(account)

    # With brownie and environment variables from the env list
    # account = accounts.add(config["wallets"]["from_key"])
    # print(account)

    ### Final version
    account = accounts[0]
    simple_storage = SimpleStorage.deploy(
        {"from": account, "gas_price": gas_strategy}
    )  # Deploy contract - always specify from which address you are deploying it from
    # print(simple_storage)
    stored_value = simple_storage.retrieve()
    print(stored_value)
    transaction = simple_storage.store(15, {"from": account})
    transaction.wait(1)  # How many blocks should you wait?
    updated_stored_value = simple_storage.retrieve()
    print(updated_stored_value)


def main():
    deploy_simple_storage()
