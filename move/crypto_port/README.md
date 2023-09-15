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


# TypeScript (1st part done)

➜  scripts git:(main) ✗ sui client publish --gas-budget 200000000
[warn] Client/Server api version mismatch, client api version : 1.9.0, server api version : 1.9.1
UPDATING GIT DEPENDENCY https://github.com/MystenLabs/sui.git
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY MoveStdlib
BUILDING crypto_port
Successfully verified dependencies on-chain against source.
----- Transaction Digest ----
2w2FrYrYuEUDsZA7NfMDFLVWyev4uxmHxZFBZUfmq7p5
----- Transaction Data ----
Transaction Signature: [Signature(Ed25519SuiSignature(Ed25519SuiSignature([0, 246, 187, 157, 76, 118, 61, 216, 0, 211, 24, 140, 139, 139, 36, 247, 241, 122, 221, 109, 229, 42, 145, 33, 114, 82, 92, 76, 142, 81, 153, 249, 214, 192, 106, 29, 230, 36, 16, 108, 12, 173, 130, 183, 71, 41, 231, 174, 19, 147, 143, 250, 46, 136, 78, 111, 29, 55, 235, 33, 64, 24, 252, 250, 4, 230, 118, 191, 24, 39, 79, 250, 209, 113, 162, 15, 105, 153, 118, 248, 76, 236, 16, 172, 237, 213, 227, 213, 253, 101, 123, 178, 46, 40, 126, 141, 166])))]
Transaction Kind : Programmable
Inputs: [Pure(SuiPureValue { value_type: Some(Address), value: "0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c" })]
Commands: [
  Publish(<modules>,0x0000000000000000000000000000000000000000000000000000000000000001,0x0000000000000000000000000000000000000000000000000000000000000002),
  TransferObjects([Result(0)],Input(0)),
]

Sender: 0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c
Gas Payment: Object ID: 0xdf7f7aa2472efe6202f7daeb9a07a7f97e5b72f1628ae19dcd3978a0b1712927, version: 0x674869, digest: CVX87JCjySXsiG61vih2gWVfGHGVQLxjiYFjnpbxu2Wy 
Gas Owner: 0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c
Gas Price: 1000
Gas Budget: 200000000

----- Transaction Effects ----
Status : Success
Created Objects:
  - ID: 0xa83f3736a9b8ab45c5f2861a0e00b16f3b99a98d68038541830bfd6b0d97661c , Owner: Account Address ( 0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c )
  - ID: 0xaca005c7b2d3dc969bdf22f0f2609af283ca293b207cfc51909cfdc9cbc08cd8 , Owner: Account Address ( 0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c )
  - ID: 0xdd38a3b4c57bd7527bc3b7b356d2781470f2078490be25d6cadd586510d5f566 , Owner: Shared
  - ID: 0xdeecae073c84ddbc55a6d7f950f7cd5bf513c7b3ff93ecb5a5a7b51cda775cde , Owner: Immutable
  - ID: 0xea94cfa0dc61b8b9830220d1bc7336fa5a6eab23f2bd16f9a8975979abed999a , Owner: Account Address ( 0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c )
Mutated Objects:
  - ID: 0xdf7f7aa2472efe6202f7daeb9a07a7f97e5b72f1628ae19dcd3978a0b1712927 , Owner: Account Address ( 0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c )

----- Events ----
Array []
----- Object changes ----
Array [
    Object {
        "type": String("mutated"),
        "sender": String("0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c"),
        "owner": Object {
            "AddressOwner": String("0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c"),
        },
        "objectType": String("0x2::coin::Coin<0x2::sui::SUI>"),
        "objectId": String("0xdf7f7aa2472efe6202f7daeb9a07a7f97e5b72f1628ae19dcd3978a0b1712927"),
        "version": String("6768746"),
        "previousVersion": String("6768745"),
        "digest": String("EfyrdipLubGcx84nW3iiWDxsdqXL7RW3kdaJMu4RLq1p"),
    },
    Object {
        "type": String("created"),
        "sender": String("0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c"),
        "owner": Object {
            "AddressOwner": String("0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c"),
        },
        "objectType": String("0x2::package::UpgradeCap"),
        "objectId": String("0xa83f3736a9b8ab45c5f2861a0e00b16f3b99a98d68038541830bfd6b0d97661c"),
        "version": String("6768746"),
        "digest": String("9AmkSwyHtUVNo4SUGV73qAYVS9biad2oS5hJ7zBGcXTT"),
    },
    Object {
        "type": String("created"),
        "sender": String("0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c"),
        "owner": Object {
            "AddressOwner": String("0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c"),
        },
        "objectType": String("0xdeecae073c84ddbc55a6d7f950f7cd5bf513c7b3ff93ecb5a5a7b51cda775cde::ride::RideReadWriteCap"),
        "objectId": String("0xaca005c7b2d3dc969bdf22f0f2609af283ca293b207cfc51909cfdc9cbc08cd8"),
        "version": String("6768746"),
        "digest": String("DcZEQfuNkxa62whKpzNPL1WMV1PiPd5VV1k8U23YxhyC"),
    },
    Object {
        "type": String("created"),
        "sender": String("0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c"),
        "owner": Object {
            "Shared": Object {
                "initial_shared_version": Number(6768746),
            },
        },
        "objectType": String("0xdeecae073c84ddbc55a6d7f950f7cd5bf513c7b3ff93ecb5a5a7b51cda775cde::ride::RidesStorage"),
        "objectId": String("0xdd38a3b4c57bd7527bc3b7b356d2781470f2078490be25d6cadd586510d5f566"),
        "version": String("6768746"),
        "digest": String("7fzCXkRNL1g83SK62Tb3gE6thZZL7awjeDxuzCoT9wTe"),
    },
    Object {
        "type": String("published"),
        "packageId": String("0xdeecae073c84ddbc55a6d7f950f7cd5bf513c7b3ff93ecb5a5a7b51cda775cde"),
        "version": String("1"),
        "digest": String("BhfuGWtKKh5jkvYv5Uzp8XmmgQXiQ1equHPaPF6F6FDt"),
        "modules": Array [
            String("ride"),
        ],
    },
    Object {
        "type": String("created"),
        "sender": String("0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c"),
        "owner": Object {
            "AddressOwner": String("0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c"),
        },
        "objectType": String("0xdeecae073c84ddbc55a6d7f950f7cd5bf513c7b3ff93ecb5a5a7b51cda775cde::ride::AdminCap"),
        "objectId": String("0xea94cfa0dc61b8b9830220d1bc7336fa5a6eab23f2bd16f9a8975979abed999a"),
        "version": String("6768746"),
        "digest": String("76mx2fHfxwoSq3jERKWaMmjeGzEbzzcG65ycZtaNws3e"),
    },
]
----- Balance changes ----
Array [
    Object {
        "owner": Object {
            "AddressOwner": String("0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c"),
        },
        "coinType": String("0x2::sui::SUI"),
        "amount": String("-29243880"),
    },
]
➜  scripts git:(main) ✗ ts-node programmable_trans.ts            
Keypair-> ADMIN 0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c
Execution status { status: 'success' }
Result {
  messageVersion: 'v1',
  status: { status: 'success' },
  executedEpoch: '127',
  gasUsed: {
    computationCost: '1000000',
    storageCost: '3632800',
    storageRebate: '2249676',
    nonRefundableStorageFee: '22724'
  },
  modifiedAtVersions: [
    {
      objectId: '0xdf7f7aa2472efe6202f7daeb9a07a7f97e5b72f1628ae19dcd3978a0b1712927',
      sequenceNumber: '6768746'
    },
    {
      objectId: '0xea94cfa0dc61b8b9830220d1bc7336fa5a6eab23f2bd16f9a8975979abed999a',
      sequenceNumber: '6768746'
    }
  ],
  transactionDigest: 'BiVikFfBBSkdfbFrE65nfHJUEdD7MpLZFNp5nf6tXJj8',
  created: [ { owner: [Object], reference: [Object] } ],
  mutated: [
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] }
  ],
  gasObject: {
    owner: {
      AddressOwner: '0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c'
    },
    reference: {
      objectId: '0xdf7f7aa2472efe6202f7daeb9a07a7f97e5b72f1628ae19dcd3978a0b1712927',
      version: 6768747,
      digest: '5tgDFmMS2eDVox8RVf6fbraYKo7WSytEYVGs496s1G3e'
    }
  },
  dependencies: [ '2w2FrYrYuEUDsZA7NfMDFLVWyev4uxmHxZFBZUfmq7p5' ]
}
Keypair-> ADMIN 0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c
Execution status { status: 'success' }
Result {
  messageVersion: 'v1',
  status: { status: 'success' },
  executedEpoch: '127',
  gasUsed: {
    computationCost: '1000000',
    storageCost: '8101600',
    storageRebate: '6101964',
    nonRefundableStorageFee: '61636'
  },
  modifiedAtVersions: [
    {
      objectId: '0xaca005c7b2d3dc969bdf22f0f2609af283ca293b207cfc51909cfdc9cbc08cd8',
      sequenceNumber: '6768746'
    },
    {
      objectId: '0xdd38a3b4c57bd7527bc3b7b356d2781470f2078490be25d6cadd586510d5f566',
      sequenceNumber: '6768746'
    },
    {
      objectId: '0xdf7f7aa2472efe6202f7daeb9a07a7f97e5b72f1628ae19dcd3978a0b1712927',
      sequenceNumber: '6768747'
    },
    {
      objectId: '0xea94cfa0dc61b8b9830220d1bc7336fa5a6eab23f2bd16f9a8975979abed999a',
      sequenceNumber: '6768747'
    }
  ],
  sharedObjects: [
    {
      objectId: '0xdd38a3b4c57bd7527bc3b7b356d2781470f2078490be25d6cadd586510d5f566',
      version: 6768746,
      digest: '7fzCXkRNL1g83SK62Tb3gE6thZZL7awjeDxuzCoT9wTe'
    }
  ],
  transactionDigest: 'D9RxEq5ehdT2iBXui4tzgN3EtZ8Q52pSV2ibdq6UFG41',
  created: [ { owner: [Object], reference: [Object] } ],
  mutated: [
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] }
  ],
  gasObject: {
    owner: {
      AddressOwner: '0x3d4780860eef73333090e307e3d0194e6968d855a825b3db101f3fc0ac55b71c'
    },
    reference: {
      objectId: '0xdf7f7aa2472efe6202f7daeb9a07a7f97e5b72f1628ae19dcd3978a0b1712927',
      version: 6768748,
      digest: 'EFpn5FEmZDpEBD34qkytqVntBGA7gxemFYBmkhk8SEA'
    }
  },
  dependencies: [
    '2w2FrYrYuEUDsZA7NfMDFLVWyev4uxmHxZFBZUfmq7p5',
    'BiVikFfBBSkdfbFrE65nfHJUEdD7MpLZFNp5nf6tXJj8'
  ]
}
Keypair->RIDER 0x999469afad7d65cd332258db9ea4a241dbaa6cf2ab7e5da730e06faca4d11494
Execution status { status: 'success' }
Result {
  messageVersion: 'v1',
  status: { status: 'success' },
  executedEpoch: '127',
  gasUsed: {
    computationCost: '1000000',
    storageCost: '8010400',
    storageRebate: '3483612',
    nonRefundableStorageFee: '35188'
  },
  modifiedAtVersions: [
    {
      objectId: '0x6b61421a1eafc90550bb85c33e40f71f76d713ff698df8686b0a336983b36c41',
      sequenceNumber: '6768746'
    },
    {
      objectId: '0xdd38a3b4c57bd7527bc3b7b356d2781470f2078490be25d6cadd586510d5f566',
      sequenceNumber: '6768748'
    }
  ],
  sharedObjects: [
    {
      objectId: '0xdd38a3b4c57bd7527bc3b7b356d2781470f2078490be25d6cadd586510d5f566',
      version: 6768748,
      digest: '47d1rftfZpovNiNaQDznq1pazNZxyy4eb59UoRLPUDwU'
    }
  ],
  transactionDigest: '6V1ri7TwJbZvbpM7KEPRSKi4jeJX5XuvhjnZhdZDPTW6',
  created: [
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] }
  ],
  mutated: [
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] }
  ],
  gasObject: {
    owner: {
      AddressOwner: '0x999469afad7d65cd332258db9ea4a241dbaa6cf2ab7e5da730e06faca4d11494'
    },
    reference: {
      objectId: '0x6b61421a1eafc90550bb85c33e40f71f76d713ff698df8686b0a336983b36c41',
      version: 6768749,
      digest: 'HCpxVjqfqz9WgdU9SukiU4YRvvNEZF6xHy2sKbQysE78'
    }
  },
  eventsDigest: 'Gtpuw4ZaCuMmUAsnQqvUkYDcSmVbkVH4wJs9sLj1je4b',
  dependencies: [
    '2w2FrYrYuEUDsZA7NfMDFLVWyev4uxmHxZFBZUfmq7p5',
    '4qQJDBduEdKmzwNXNKFNbCMVtXXFXPRHYsTsovrGP7Hq',
    'D9RxEq5ehdT2iBXui4tzgN3EtZ8Q52pSV2ibdq6UFG41'
  ]
}
Events [
  {
    id: {
      txDigest: '6V1ri7TwJbZvbpM7KEPRSKi4jeJX5XuvhjnZhdZDPTW6',
      eventSeq: '0'
    },
    packageId: '0xdeecae073c84ddbc55a6d7f950f7cd5bf513c7b3ff93ecb5a5a7b51cda775cde',
    transactionModule: 'ride',
    sender: '0x999469afad7d65cd332258db9ea4a241dbaa6cf2ab7e5da730e06faca4d11494',
    type: '0xdeecae073c84ddbc55a6d7f950f7cd5bf513c7b3ff93ecb5a5a7b51cda775cde::ride::Ride_Request',
    parsedJson: {
      ride_adr: '0x0d351f995d00d8649ec085578509a3b2e6f0b4a4af0ff20a53c7effbdd9004c4'
    },
    bcs: 'tZHQ2AUH9Eckm7SEyV8vPsJYXU33oVqzRKLC2iBQJkB'
  }
]
ride id 0x0d351f995d00d8649ec085578509a3b2e6f0b4a4af0ff20a53c7effbdd9004c4
Keypair->DRIVER 0x0502949fb92ef508ec5a44052df6732799d481f508fb91a9f1e2c630908d3e09
Execution status { status: 'success' }
Result {
  messageVersion: 'v1',
  status: { status: 'success' },
  executedEpoch: '127',
  gasUsed: {
    computationCost: '1000000',
    storageCost: '10191600',
    storageRebate: '9848916',
    nonRefundableStorageFee: '99484'
  },
  modifiedAtVersions: [
    {
      objectId: '0x5e29164293f1edf2114b9506ca64c807e76abf74111ed6786d9f98e35d6b3aa0',
      sequenceNumber: '6768725'
    },
    {
      objectId: '0x62727ee482a5d53507b3222c90ffbc569a49376602b10f4dcfaaf0f4ed0309e8',
      sequenceNumber: '6768748'
    },
    {
      objectId: '0x73931d82e315d4f837ba75fa79a86d211764a381810c1328105822670b5bda82',
      sequenceNumber: '6768749'
    },
    {
      objectId: '0xb4c41dd651544207c9adbd61e4bc569d81d385d9f63f57b039cc4eb57577e250',
      sequenceNumber: '6768749'
    },
    {
      objectId: '0xdd38a3b4c57bd7527bc3b7b356d2781470f2078490be25d6cadd586510d5f566',
      sequenceNumber: '6768749'
    }
  ],
  sharedObjects: [
    {
      objectId: '0xdd38a3b4c57bd7527bc3b7b356d2781470f2078490be25d6cadd586510d5f566',
      version: 6768749,
      digest: '7H8i2x3ZcVJf3qP4JGpQ5CUfY4BfhN1sfYkK4KYRa5DN'
    }
  ],
  transactionDigest: 'mWewk6XjxH8gTuWxjFdZvsQtqY63JPfdwf9wWzAWkuH',
  mutated: [
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] }
  ],
  gasObject: {
    owner: {
      AddressOwner: '0x0502949fb92ef508ec5a44052df6732799d481f508fb91a9f1e2c630908d3e09'
    },
    reference: {
      objectId: '0x5e29164293f1edf2114b9506ca64c807e76abf74111ed6786d9f98e35d6b3aa0',
      version: 6768750,
      digest: 'EBVkGg6nTUf7db1YXfP7kvYPJj5Q2iNChGWN3gvcxsBP'
    }
  },
  dependencies: [
    'gMtXTNJeK3wruEm5eD6sRc48ZL6LbcqzZMD1t3o1QSm',
    '2w2FrYrYuEUDsZA7NfMDFLVWyev4uxmHxZFBZUfmq7p5',
    '6V1ri7TwJbZvbpM7KEPRSKi4jeJX5XuvhjnZhdZDPTW6'
  ]
}
Keypair 0x0502949fb92ef508ec5a44052df6732799d481f508fb91a9f1e2c630908d3e09
Execution status { status: 'success' }
Result {
  messageVersion: 'v1',
  status: { status: 'success' },
  executedEpoch: '127',
  gasUsed: {
    computationCost: '1000000',
    storageCost: '10252400',
    storageRebate: '10089684',
    nonRefundableStorageFee: '101916'
  },
  modifiedAtVersions: [
    {
      objectId: '0x5e29164293f1edf2114b9506ca64c807e76abf74111ed6786d9f98e35d6b3aa0',
      sequenceNumber: '6768750'
    },
    {
      objectId: '0x62727ee482a5d53507b3222c90ffbc569a49376602b10f4dcfaaf0f4ed0309e8',
      sequenceNumber: '6768750'
    },
    {
      objectId: '0x73931d82e315d4f837ba75fa79a86d211764a381810c1328105822670b5bda82',
      sequenceNumber: '6768750'
    },
    {
      objectId: '0xb4c41dd651544207c9adbd61e4bc569d81d385d9f63f57b039cc4eb57577e250',
      sequenceNumber: '6768750'
    },
    {
      objectId: '0xdd38a3b4c57bd7527bc3b7b356d2781470f2078490be25d6cadd586510d5f566',
      sequenceNumber: '6768750'
    }
  ],
  sharedObjects: [
    {
      objectId: '0xdd38a3b4c57bd7527bc3b7b356d2781470f2078490be25d6cadd586510d5f566',
      version: 6768750,
      digest: '5s6HdNrzRKyDpWZwqFyj2uVQuZYBf47Jmup9o182e4P4'
    }
  ],
  transactionDigest: '9xmrdcCR4D5PCsAM5Wxr1z1hH2bL5qaBtr5H4d8TywYf',
  mutated: [
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] },
    { owner: [Object], reference: [Object] }
  ],
  gasObject: {
    owner: {
      AddressOwner: '0x0502949fb92ef508ec5a44052df6732799d481f508fb91a9f1e2c630908d3e09'
    },
    reference: {
      objectId: '0x5e29164293f1edf2114b9506ca64c807e76abf74111ed6786d9f98e35d6b3aa0',
      version: 6768751,
      digest: 'Gw9uxUYkz7bULguDMadrsyhasnDSrH8csajpPCZvYMts'
    }
  },
  dependencies: [
    'mWewk6XjxH8gTuWxjFdZvsQtqY63JPfdwf9wWzAWkuH',
    '2w2FrYrYuEUDsZA7NfMDFLVWyev4uxmHxZFBZUfmq7p5'
  ]
}
