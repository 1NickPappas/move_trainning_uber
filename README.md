#!/bin/bash

# CryptoPort Integration with Sui - Move/TypeScript Exercise


# Exercise Overview

CryptoPort aims to build an "UBER on chain" platform with the following actors and functionalities:

### Actors

- **Rider**: Requests rides and can have a limited number of completed rides.
- **Driver**: Accepts ride requests, completes rides, and can be activated or deactivated by the Admin.
- **Admin (Partner)**: Manages drivers and oversees the platform.

### Use Case Flow

1. A Rider requests a ride.
2. A Driver accepts the ride request.
3. The Driver completes the ride upon reaching the destination.

### Ride Information

Each ride must contain the following fields:

- `estimate_distance`: The initial distance provided by the rider.
- `actual_distance`: The distance traveled by the Driver.
- `rider_id`: Unique identifier for the Rider.
- `driver_id`: Unique identifier for the Driver.
- `state`: The state of the ride (e.g., pending, accepted, completed, cancelled).

All ride data must be securely stored on the blockchain.

### Specific Rules

- A ride can only be accepted by one Driver.
- A Rider can only have one ride that is pending or accepted.
- A Rider with 10 completed rides will receive a free ride ticket.

# Smart Contract Structure and Functions

The provided Move smart contract is structured as follows, with detailed explanations of key components and functions:

- **AdminCap**: Represents the Admin's capabilities and is used for administrative purposes.
- **RideReadWriteCap**: Represents the Driver's capabilities, including their status (active or inactive).

- **Ride**: Stores ride information, including distance, state, and participant addresses.
- **RidesStorage**: Central storage for ride-related data, including Rider and Driver details, completed rides, and the main list of rides.
- **Driver**: Represents a Driver, indicating whether they are currently processing a ride.

- **Rider**: Represents a Rider, indicating whether they are currently processing a ride and the number of completed rides.

- **State**: Used to change the state of a ride (e.g., accepted, completed, cancelled).

- **Actual_distance**: Used to change the actual distance traveled during a ride.

### Functions

- `init(ctx: &mut TxContext)`: The initialization function called during deployment. It creates essential tables and transfers capabilities to the Admin and Driver.

- `create_driver(_:&AdminCap ,ctx: &mut TxContext)`: Creates a new Driver and returns their capabilities. Only the Admin can call this function.

- `send_driver_cap(_: &AdminCap,info: &mut RidesStorage,driver_cap : RideReadWriteCap, recipient: address)`: Transfers Driver capabilities to a specific recipient and adds the Driver to the Driver list.

- `request_ride(info: &mut RidesStorage, estimate_distance: u64, ctx: &mut TxContext)`: Allows a Rider to request a ride, checking Rider status and adding the ride to the list.

- `get_rides(info: &RidesStorage)`: Returns the list of rides stored in the RidesStorage.

- `is_rider_processing(infos: &RidesStorage, rider: address)`: Checks if a Rider is currently processing a ride.

- `is_driver_processing(infos:&mut RidesStorage,driver : address)`: Checks if a Driver is currently processing a ride.

- `accept_ride(infos: &mut RidesStorage, ride_id : address, ctx: &mut TxContext)`: Allows a Driver to accept a ride, updating the ride's state and Driver status.

- `get_ride_state(infos: &RidesStorage, ride_id: address)`: Retrieves the state of a specific ride.

- `end_ride(infos: &mut RidesStorage, ride_address: address, actual_distance: u64, ctx: &mut TxContext)`: Marks a ride as completed by a Driver, updating the state and relevant statuses.



# Test Scenarios Overview

The test code provided below is used to test the CryptoPort smart contract. It covers various scenarios to ensure the contract works as expected. Below is an explanation of the key test scenarios:

## `test_init`

- Initializes the contract, creating essential tables and transferring capabilities to the admin and driver.

## `test_end_ride_scenario`

- Tests the entire ride flow, including rider request, driver acceptance, and ride completion. It checks if rider and driver states are correctly updated.

## `test_create_send_ridereadwritecap_scenario`

- Tests the creation and transfer of `RideReadWriteCap` from the admin to the driver. This scenario is used in other tests.

## `test_create_send_ridereadwritecap_scenario_t`

- Tests the creation and transfer of `RideReadWriteCap` separately to verify that it can be created and passed from the admin to the driver.

## `test_rider_proccesing_t`

- Tests if a rider can request multiple rides simultaneously, which should result in an error.

## `test_driver_not_at_ride_t`

- Tests if a driver who is not associated with any ride can interact with the contract, which should result in an error.

## `test_rider_request_ride_will_otherone_proccesing_s`

- Tests if a rider can request a new ride while another ride is already accepted by a different driver, which should result in an error.

## `test_driver_not_at_ride_end_ride_s`

- Tests if a driver who is not associated with the ride tries to end the ride, which should result in an error.

## `test_driver_not_at_ride_end_ride_s2`

- Tests if a driver who is not associated with the ride tries to end the ride when another driver is also listed, which should result in an error.

## `call_end_ride_for_no_existed_ride`

- Tests if a driver tries to end a ride that does not exist in the rides list, which should result in an error.

## `not_listed_driver_try_to_accept_ride`

- Tests if a driver who is not listed in the driver's list tries to accept a ride, which should result in an error.

## `driver_try_to_accept_not_existed_ride`

- Tests if a driver with a driver cap tries to accept a ride that does not exist in the rides list, which should result in an error.

## `call_is_rider_processing_for_not_existed_ride`

- Tests if the `is_rider_processing` function is called for a rider who is not in the list, which should result in an error.

## `call_is_driver_processing_for_not_existed_ride`

- Tests if the `is_driver_processing` function is called for a driver who is not in the list, which should result in an error.

## `call_request_ride_when_rider_already_processing`

- Tests if a rider can request another ride while already processing one, which should result in an error.

# Running the Tests

➜  crypto_port git:(main) ✗ sui move test --coverage 

UPDATING GIT DEPENDENCY https://github.com/MystenLabs/sui.git
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY MoveStdlib
BUILDING crypto_port
Running Move unit tests
[ PASS    ] 0x0::ride_tests::call_end_ride_for_no_existed_ride
[ PASS    ] 0x0::ride_tests::call_is_driver_processing_for_not_existed_ride
[ PASS    ] 0x0::ride_tests::call_is_rider_processing_for_not_existed_ride
[ PASS    ] 0x0::ride_tests::call_request_ride_when_rider_already_processing
[ PASS    ] 0x0::ride_tests::driver_try_to_accept_not_existed_ride
[ PASS    ] 0x0::ride_tests::not_listed_driver_try_to_accept_ride
[ PASS    ] 0x0::ride_tests::test_create_send_ridereadwritecap_scenario_t
[ PASS    ] 0x0::ride_tests::test_driver_not_at_ride_end_ride_s
[ PASS    ] 0x0::ride_tests::test_driver_not_at_ride_end_ride_s2
[ PASS    ] 0x0::ride_tests::test_driver_not_at_ride_t
[ PASS    ] 0x0::ride_tests::test_end_ride_scenario
[ PASS    ] 0x0::ride_tests::test_init
[ PASS    ] 0x0::ride_tests::test_rider_proccesing_t
[ PASS    ] 0x0::ride_tests::test_rider_request_ride_will_otherone_proccesing_s
Test result: OK. Total tests: 14; passed: 14; failed: 0

➜  crypto_port git:(main) ✗ sui move coverage summary             
warning[W09008]: unused function
    ┌─ ./sources/Ride.move:131:9
    │
131 │     fun init(ctx: &mut TxContext) {
    │         ^^^^ The non-'public', non-'entry' function 'init' is never called. Consider removing it.
    │
    = This warning can be suppressed with '#[allow(unused_function)]' applied to the 'module' or module member ('const', 'fun', or 'struct')

+-------------------------+
| Move Coverage Summary   |
+-------------------------+
Module 0000000000000000000000000000000000000000000000000000000000000000::ride
>>> % Module coverage: 100.00
+-------------------------+
| % Move Coverage: 100.00  |
+-------------------------+




# Coding Standards

Please ensure that you follow these coding standards while working on this exercise:

- [Sui Development Cheat Sheet](https://docs.sui.io/devnet/build/dev_cheat_sheet)
- [Move Language Coding Conventions](https://move-language.github.io/move/coding-conventions.html)

