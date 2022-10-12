from brownie import accounts, config


def deploy_simple_storage():
    # account = accounts[0]  If we want to use our local network with ganache

    # with brownie
    # account = accounts.load("freecodecamp-account")
    # print(account)

    # With brownie and environment variables from the env list
    account = accounts.add(config["wallets"]["from_key"])
    print(account)


def main():
    deploy_simple_storage()
