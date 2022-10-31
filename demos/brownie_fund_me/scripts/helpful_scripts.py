from brownie import network, config, accounts
from scripts.helpful_scripts import get_account


def get_account():
    if netowrk.show_active() == "development":
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])

