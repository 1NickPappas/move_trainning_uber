#[test_only]
module crypto_port::ride_tests {
    // Imports
    use sui::table::{Self};
    use sui::test_scenario::{Self, Scenario};
    use crypto_port::ride::{Self, RideReadWriteCap, RidesStorage};
    // use std::debug::{Self};

    const ERideReadWriteCapNotCreated: u64 = 0;
    const ERidesStorageFalselyInitialized: u64 = 1;
    const ERideDoesNotExist: u64 = 2;
    const EWrongRiderState: u64 = 3;
    const EWrongDriverState: u64 = 4;
    const EWrongRideState: u64 = 5;

    #[test]
    fun test_init() {
        let admin = @0xAAAA;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        initialize(scenario, admin);

        // Test that the admin got the RideReadWriteCap
        // and that the rides storage object was created
        test_scenario::next_tx(scenario, admin);
        {
            //Check RideReadWriteCap was created and passed to admin
            let ride_owner_cap = test_scenario::take_from_sender<RideReadWriteCap>(scenario);
            // debug::print(&ride_owner_cap);
            test_scenario::return_to_sender(scenario, ride_owner_cap);
            
            //Check RidesStorage was created and initialized
            let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
            let rides = crypto_port::ride::get_rides(&rides_storage);
            let rides_length = table::length(rides);
            assert!(rides_length == 0, ERidesStorageFalselyInitialized);
            test_scenario::return_shared<RidesStorage>(rides_storage);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_end_ride_scenario() {
        let admin = @0xAAAA;
        let rider = @0xBBBB;
        let driver = @0xCCCC;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        initialize(scenario, admin);
        let _ride_id: address = @0xAAAA;

        test_scenario::next_tx(scenario, rider);
        {
            let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);

            _ride_id = ride::request_ride(&mut rides_storage, 14, test_scenario::ctx(scenario));
            // debug::print(string::utf8(b"Start ride_id:"));
            // debug::print(&_ride_id);
            
            let rides = crypto_port::ride::get_rides(&mut rides_storage);
            let rides_length = table::length(rides);
            assert!(rides_length == 1, ERideDoesNotExist);

            let is_rider_processing: bool = ride::is_rider_processing(&mut rides_storage, rider);
            assert!(is_rider_processing == true, EWrongRiderState);

            let is_driver_processing: bool = ride::is_driver_processing(&mut rides_storage, driver);
            assert!(is_driver_processing == false, EWrongDriverState);
            test_scenario::return_shared<RidesStorage>(rides_storage);
        };

        test_scenario::next_tx(scenario, driver);
        {
            let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
            ride::accept_ride(&mut rides_storage, _ride_id, test_scenario::ctx(scenario));
            let ride_state: u16 = ride::get_ride_state(&mut rides_storage, _ride_id);
            assert!(ride_state == 2, EWrongRideState);
            
            let is_rider_processing: bool = ride::is_rider_processing(&mut rides_storage, rider);
            assert!(is_rider_processing == true, EWrongRiderState);

            let is_driver_processing: bool = ride::is_driver_processing(&mut rides_storage, driver);
            assert!(is_driver_processing == true, EWrongDriverState);
            test_scenario::return_shared<RidesStorage>(rides_storage);
        };

        test_scenario::next_tx(scenario, driver);
        {
            let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
            ride::end_ride(&mut rides_storage, _ride_id, 4, test_scenario::ctx(scenario));
            
            let ride_state: u16 = ride::get_ride_state(&mut rides_storage, _ride_id);
            assert!(ride_state == 6, EWrongRideState);
            
            let is_rider_processing: bool = ride::is_rider_processing(&mut rides_storage, rider);
            assert!(is_rider_processing == false, EWrongRiderState);

            let is_driver_processing: bool = ride::is_driver_processing(&mut rides_storage, driver);
            assert!(is_driver_processing == false, EWrongDriverState);
            test_scenario::return_shared<RidesStorage>(rides_storage);
        };

        test_scenario::end(scenario_val);
    }

    // Helper functions
    fun initialize(scenario: &mut Scenario, admin: address) {
        test_scenario::next_tx(scenario, admin);
        {
            ride::test_init(
                test_scenario::ctx(scenario),
            );
        };
    }

}