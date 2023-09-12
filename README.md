# Exercise (Beginner) Move/Typescript

## Prerequisites

- Needs to have completed the basic Move training (including object management, dynamic fields)

- Needs to have a solid understanding and/or have completed the [Udemy, TS course](https://www.udemy.com/course/typescript-for-professionals/learn/lecture/21434252#overview) and have read through the Typescript SUI SDK documentation (https://docs.sui.io/build/prog-trans-ts-sdk).

## Requirements

Company CryptoPort wants to integrate with Sui. Their use case is the following:

- The main idea is an UBER on chain
- There are three actors Rider, Driver and the Partner itself (Admin)
- The flow is as follows: A Rider is requesting a ride, a Driver accepts the ride and terminates it when they arrive at destination
- A Ride should at least contain the following fields:
    1. estimate_distance (the initial distance given by backend )
    2. actual_distance (the distance that the Driver went given by Driver)
    3. rider_id
    4. driver_id
    5. state (this can be pending, accepted, completed, cancelled)
- All Rides should be saved on chain
- A Ride can only be accepted by one Driver
- A Rider can only have one Ride that is pending or accepted
- A Rider with 10 completed rides will get a get free Ride ticket

**Note:** You will receive a set of Move tests that comply with the expected design of the exercise. 

## Deliverable

- Expected duration: 1 week
- Smart contract with as many unit tests as time allows (if short on time write the function definition and explain with comments)
- Typescript examples for the following flows
    1. Rider requests Ride, Driver accepts ride and completes it
    2. Rider requests Ride, Driver accepts, Rider cancels
- Coding standards as much as possibly followed:
    - https://docs.sui.io/devnet/build/dev_cheat_sheet
    - https://move-language.github.io/move/coding-conventions.html