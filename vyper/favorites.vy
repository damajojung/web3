# pragma version 0.4.1
# @license MIT

# EVM: Ethereum Virtual Machine
# Ethereum, Arbitrum, Optimism, ZKsync


# ----------------------------------------- Theory

# ----- pure and view

# @pure - do not read any state and global variables

# here is an example
# @external 
# @pure def (addx: uint256, y: uint256) -> uint256:
#    return x + y

# @view - read state and global variables
# count: public(uint256)
# @external 
# @pure def (addx: uint256, y: uint256) -> uint256:
#    self.count += 1
#    return x + y


# ----- ifelse

# @external 
# @pure 
# def if_else(x: uint256) -> uint256:
#     if x <= 10:
#         return 1
#     elif x<= 20:
#         return 2
#     else:
#         return 0
        
# # ----- for loop    
# @external 
# def while_loop(n: uint256):
#     x = 0
#     for i in range(n):
#         x += 1 # this is not a pure function, so we need to read the state and global variables
#     return x
        
# # ----- ifelse on an array (in fact it's just another case of while loop)
# @external 
# def else_if(x: uint256[3]): # here I do not use a @view function because we need to read the state and global variables    
#     for i in rangereturn 2
# else:
#     return 0


# ----------------------------------------- End theory

# this is a struct - looks a bit like a mini object
struct Person:
    favorite_number: uint256
    name: String[100]

struct Object:
    value: uint256
    name: String[100]

# these are just variables
my_name: public(String[100])
my_favorite_number: public(uint256) # 7
index: public(uint256)
object: Object


# these are lists - I think they are specified by []
list_of_numbers: public(uint256[5])  # 0,0,0,0,0
list_of_people: public(Person[5])

# this is a hashmap - something like a dictionnary
# if we provide this hasmap with a string, it will return a uint256
name_to_favorite_number: public( HashMap[String[100], uint256] )

@deploy
def __init__():
    self.my_favorite_number = 123
    self.index = 0
    self.my_name = "David"
    self.object = Object(value = 100, name = "silver")

@external
def store(new_number: uint256):
    self.my_favorite_number = new_number

@external
def add():
    self.my_favorite_number += 1

@external
@view
def retrieve() -> uint256:
    return self.my_favorite_number

@external
def update_object(new_value: uint256, new_object_name: String[100]):
    new_object: Object = Object(value = new_value, name = new_object_name)
    self.object = new_object

@external
@view
def retrieve_obejct() -> Object:
    return self.object

@external 
def add_person(name: String[100], favorite_number: uint256):
    # Add favorite number to the numbers list
    self.list_of_numbers[self.index] = favorite_number

    # Add the person to the person's list
    new_person: Person = Person(favorite_number = favorite_number, name = name)
    self.list_of_people[self.index] = new_person

    # Add the person to the hashmap
    self.name_to_favorite_number[name] = favorite_number

    self.index = self.index + 1
