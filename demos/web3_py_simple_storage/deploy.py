from solcx import compile_standard
import json
from web3 import Web3
import os
from dotenv import load_dotenv

load_dotenv()
# solcx.install_solc("0.8.0")

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()

# Compile our solidity

compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    },
    solc_version="0.8.0",
)

with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)

# Get bytecode (Walk down the json file -> ladder structure)
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# get ABI
abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

#####
# DEPLOY
#####

# Where should we deploy it to? We can do it with Ganache
# for connecting with ganache
w3 = Web3(
    Web3.HTTPProvider("http://127.0.0.1:8545")
)  # Change this with URL in order to connect with main or test net
chain_id = 1337
my_address = "0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1"
private_key = os.getenv("PRIVATE_KEY")


# Create the contract in python
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
# Get latest transaction
nonce = w3.eth.getTransactionCount(my_address)

# 1. Build transaction
# 2. Sign transaction
# 3. Send transaction
transaction = SimpleStorage.constructor().buildTransaction(
    {
        "gasPrice": w3.eth.gas_price,
        "chainId": chain_id,
        "from": my_address,
        "nonce": nonce,
    }
)

signed_txn = w3.eth.account.sign_transaction(transaction, private_key=private_key)

# send this signed transaction
tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(
    tx_hash
)  # This will stop the code until the transaction goes through

# Working with a contract, you always need: Contract address & ABI

simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
# Call ->   Simuate making the call and getting the value - they do not change the blockchain - blue buttons in remix
# Transact -> Actually make a state change - orange buttons in remix


### Short input on call()
# This is the initial value of favoriteNumber
# print(simple_storage.functions.retrieve().call())
# print(simple_storage.functions.store(15).call())
# print(
#     simple_storage.functions.retrieve().call()
# )  # We see it is still 0 - we are not working on the chain - calling is just a simulation

# 0
# 15
# 0
# ##

# Working with deployed Contracts
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
print(f"Initial Stored Value {simple_storage.functions.retrieve().call()}")
greeting_transaction = simple_storage.functions.store(15).buildTransaction(
    {
        "chainId": chain_id,
        "gasPrice": w3.eth.gas_price,
        "from": my_address,
        "nonce": nonce + 1,
    }
)
signed_greeting_txn = w3.eth.account.sign_transaction(
    greeting_transaction, private_key=private_key
)
tx_greeting_hash = w3.eth.send_raw_transaction(signed_greeting_txn.rawTransaction)
print("Updating stored Value...")
tx_receipt = w3.eth.wait_for_transaction_receipt(
    tx_greeting_hash
)  # This updated the blockchain and was actually sent to it

print(simple_storage.functions.retrieve().call())
