from brownie import SimpleStorage, accounts


def test_deploy():
    # Testing a contract is separated in 3 cotegories:
    # Arrange
    account = accounts[0]
    # Act
    simple_storage = SimpleStorage.deploy({"from": account})
    starting_value = simple_storage.retrieve()
    expected = 0
    # Assert
    assert starting_value == expected

