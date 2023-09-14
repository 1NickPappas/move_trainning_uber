#[test_only]
module crypto_port::ride_tests {
    // Imports
    use sui::table::{Self};
    use sui::test_scenario::{Self, Scenario};
    use crypto_port::ride::{Self, RideReadWriteCap, RidesStorage, AdminCap};
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
        let _ride_id: address;
        

        initialize(scenario, admin);
        test_create_send_ridereadwritecap_scenario(scenario, admin, driver);

        

        test_scenario::next_tx(scenario, rider);
    
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
    

        test_scenario::next_tx(scenario, driver);
        
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        ride::accept_ride(&mut rides_storage, _ride_id, test_scenario::ctx(scenario));
        let ride_state: u16 = ride::get_ride_state(&mut rides_storage, _ride_id);
        assert!(ride_state == 2, EWrongRideState);
        
        let is_rider_processing: bool = ride::is_rider_processing(&mut rides_storage, rider);
        assert!(is_rider_processing == true, EWrongRiderState);

        let is_driver_processing: bool = ride::is_driver_processing(&mut rides_storage, driver);
        assert!(is_driver_processing == true, EWrongDriverState);
        test_scenario::return_shared<RidesStorage>(rides_storage);
    

        test_scenario::next_tx(scenario, driver);
        
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        ride::end_ride(&mut rides_storage, _ride_id, 4, test_scenario::ctx(scenario));
        
        let ride_state: u16 = ride::get_ride_state(&mut rides_storage, _ride_id);
        assert!(ride_state == 6, EWrongRideState);
        
        let is_rider_processing: bool = ride::is_rider_processing(&mut rides_storage, rider);
        assert!(is_rider_processing == false, EWrongRiderState);

        let is_driver_processing: bool = ride::is_driver_processing(&mut rides_storage, driver);
        assert!(is_driver_processing == false, EWrongDriverState);
        test_scenario::return_shared<RidesStorage>(rides_storage);

        // rider request a new ride
        test_scenario::next_tx(scenario, rider);
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        let _ride_id_2 = ride::request_ride(&mut rides_storage, 14, test_scenario::ctx(scenario));
        // test if rider is processing
        let is_rider_processing: bool = ride::is_rider_processing(&mut rides_storage, rider);
        assert!(is_rider_processing == true, EWrongRiderState);
        test_scenario::return_shared<RidesStorage>(rides_storage);
    

        test_scenario::end(scenario_val);
    }

    //tests from me //////////////////////////////////////////////////////////
     //this will test if the RideReadWriteCap can be created and passed from the admin to the driver

    fun test_create_send_ridereadwritecap_scenario(scenario: &mut Scenario, admin: address, driver: address){

        test_scenario::next_tx(scenario, admin);
        
        let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        
        let ridereadwritecap = ride::create_driver(&admin_cap,test_scenario::ctx(scenario));

        // test_scenario::return_to_sender(scenario, ridereadwritecap);
        ride::send_driver_cap(&admin_cap,&mut rides_storage, ridereadwritecap, driver);

        test_scenario::return_shared<RidesStorage>(rides_storage);
        test_scenario::return_to_sender(scenario, admin_cap);
            
        

    }

    #[test] // this will test if the RideReadWriteCap can be created and passed from the admin to the driver
    fun test_create_send_ridereadwritecap_scenario_t(){
        let admin = @0xAAAA;
        let driver = @0xCCCC;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        initialize(scenario, admin);

        test_create_send_ridereadwritecap_scenario(scenario, admin, driver);

        test_scenario::end(scenario_val);
    }

    ////////////////////////////////////////////////////////////////////////
    #[test]
    #[expected_failure(abort_code=ride::EWrongRiderState)]
    fun test_rider_proccesing_t(){
        let admin = @0xAAAA;
        let rider = @0xBBBB;
        let driver = @0xCCCC;
        // let driver_random_id: address = @0xDDDF;
        // let ride_random_id: address = @0xDDDD;

        let scenario_val = test_scenario::begin(rider);
        let scenario = &mut scenario_val;

        initialize(scenario, admin); 
        // this make and send from admin to driver the RideReadWriteCap
        test_create_send_ridereadwritecap_scenario(scenario, admin, driver);
        test_scenario::next_tx(scenario, rider); // this test if the rider is proccesing before do anything
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);

        ride::request_ride(&mut rides_storage, 14, test_scenario::ctx(scenario));
        ride::request_ride(&mut rides_storage, 25, test_scenario::ctx(scenario));
        test_scenario::return_shared<RidesStorage>(rides_storage);
        test_scenario::end(scenario_val);
    }

    // this will test if a rider request two rides at the same time
    #[test]
    #[expected_failure(abort_code=ride::EWrongRiderState)]
    fun test_driver_not_at_ride_t(){
        let admin = @0xAAAA;
        let rider = @0xBBBB;
        let driver = @0xCCCC;

        let scenario_val = test_scenario::begin(rider);
        let scenario = &mut scenario_val;

        initialize(scenario, admin); 
        // this make and send from admin to driver the RideReadWriteCap
        test_create_send_ridereadwritecap_scenario(scenario, admin, driver);
        test_scenario::next_tx(scenario, rider); // this test if the rider is proccesing before do anything
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        ride::request_ride(&mut rides_storage, 14, test_scenario::ctx(scenario));
        // check the rider state
        let is_rider_processing: bool = ride::is_rider_processing(&mut rides_storage, rider);
        assert!(is_rider_processing == true, EWrongRiderState);

        ride::request_ride(&mut rides_storage, 25, test_scenario::ctx(scenario));
        // check the rider state
        let is_rider_processing: bool = ride::is_rider_processing(&mut rides_storage, rider);
        assert!(is_rider_processing == true, EWrongRiderState);
        test_scenario::return_shared<RidesStorage>(rides_storage);
        test_scenario::end(scenario_val);
    }

    // this will test if a rider request a ride when other ride is accepted from driver
    #[test]
    #[expected_failure(abort_code=ride::EWrongRiderState)]
    fun test_rider_request_ride_will_otherone_proccesing_s(){
        let admin = @0xAAAA;
        let rider = @0xBBBB;
        let driver = @0xCCCC;

        let scenario_val = test_scenario::begin(rider);
        let scenario = &mut scenario_val;

        initialize(scenario, admin); 
        // this make and send from admin to driver the RideReadWriteCap
        test_create_send_ridereadwritecap_scenario(scenario, admin, driver);
        test_scenario::next_tx(scenario, rider); // this test if the rider is proccesing before do anything
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        let ride_id= ride::request_ride(&mut rides_storage, 14, test_scenario::ctx(scenario));
        // check the rider state
        let is_rider_processing: bool = ride::is_rider_processing(&mut rides_storage, rider);
        assert!(is_rider_processing == true, EWrongRiderState);
        // next tx driver accept the ride
        test_scenario::next_tx(scenario, driver);
        ride::accept_ride(&mut rides_storage, ride_id, test_scenario::ctx(scenario));
        
        // next tx while ride accepted from driver the rider request a new ride
        test_scenario::next_tx(scenario, rider);

        ride::request_ride(&mut rides_storage, 25, test_scenario::ctx(scenario));
        // check the rider state

        test_scenario::return_shared<RidesStorage>(rides_storage);
        test_scenario::end(scenario_val);
    }

    // this will test if a driver that is not the driver of the ride try to end the ride(driver not in list)
    #[test]
    #[expected_failure(abort_code=ride::EDriverNotInList)]
    fun test_driver_not_at_ride_end_ride_s(){
        let admin = @0xAAAA;
        let rider = @0xBBBB;
        let driver = @0xCCCC;
        let driver_random_id: address = @0xDDDF;

        let scenario_val = test_scenario::begin(rider);
        let scenario = &mut scenario_val;

        initialize(scenario, admin); 
        // this make and send from admin to driver the RideReadWriteCap
        test_create_send_ridereadwritecap_scenario(scenario, admin, driver);
        test_scenario::next_tx(scenario, rider); // this test if the rider is proccesing before do anything
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        let ride_id= ride::request_ride(&mut rides_storage, 14, test_scenario::ctx(scenario));
        // check the rider state
        let is_rider_processing: bool = ride::is_rider_processing(&mut rides_storage, rider);
        assert!(is_rider_processing == true, EWrongRiderState);
        // next tx driver accept the ride
        test_scenario::next_tx(scenario, driver);
        ride::accept_ride(&mut rides_storage, ride_id, test_scenario::ctx(scenario));
        
        // next tx while ride accepted from driver the rider request a new ride
        test_scenario::next_tx(scenario, driver_random_id);

        ride::end_ride(&mut rides_storage, ride_id, 4, test_scenario::ctx(scenario));
        // check the rider state

        test_scenario::return_shared<RidesStorage>(rides_storage);
        test_scenario::end(scenario_val);
    }

    // this will test if a driver that is not the driver of the ride try to end the ride(driver and random driver in list)
    #[test]
    #[expected_failure(abort_code=ride::EDriverNotAtRide)]
    fun test_driver_not_at_ride_end_ride_s2(){
        let admin = @0xAAAA;
        let rider = @0xBBBB;
        let rider_2 = @0xBBBC;
        let driver = @0xCCCC;
        let driver_random_id: address = @0xDDDF;

        let scenario_val = test_scenario::begin(rider);
        let scenario = &mut scenario_val;

        initialize(scenario, admin); 
        // this make and send from admin to driver the RideReadWriteCap
        test_create_send_ridereadwritecap_scenario(scenario, admin, driver); // this make and send from admin to driver the RideReadWriteCap
        test_create_send_ridereadwritecap_scenario(scenario, admin, driver_random_id); // this make and send from admin to driver_random_id the RideReadWriteCap
        test_scenario::next_tx(scenario, rider); // this test if the rider is proccesing before do anything
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        let ride_id= ride::request_ride(&mut rides_storage, 14, test_scenario::ctx(scenario));
        // check the rider state
        let is_rider_processing: bool = ride::is_rider_processing(&mut rides_storage, rider);
        assert!(is_rider_processing == true, EWrongRiderState);
        // next tx driver accept the ride
        test_scenario::next_tx(scenario, driver);
        ride::accept_ride(&mut rides_storage, ride_id, test_scenario::ctx(scenario));
        //next tx rider_2 request other ride
        test_scenario::next_tx(scenario, rider_2);
        let ride_id_2= ride::request_ride(&mut rides_storage, 14, test_scenario::ctx(scenario));
        // next tx driver accept the ride
        test_scenario::next_tx(scenario, driver_random_id);
        ride::accept_ride(&mut rides_storage, ride_id_2, test_scenario::ctx(scenario));

        // next tx while ride accepted from driver the rider request a new ride
        test_scenario::next_tx(scenario, driver_random_id);
        ride::end_ride(&mut rides_storage, ride_id, 4, test_scenario::ctx(scenario));
        // check the rider state

        test_scenario::return_shared<RidesStorage>(rides_storage);
        test_scenario::end(scenario_val);
    }

    // this test will test if a driver try to end a ride that is not existed in rides list
    #[test]
    #[expected_failure(abort_code=ride::ERideDoesNotExist)]
    fun call_end_ride_for_no_existed_ride(){
        let admin = @0xAAAA;
        // let rider = @0xBBBB;
        let driver = @0xCCCC;
        let ride_random_id: address = @0xDDDD;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        initialize(scenario, admin);
        test_create_send_ridereadwritecap_scenario(scenario, admin, driver); // this make and send from admin to driver the RideReadWriteCap

        // driver try to end the ride but the ride does not exist
        test_scenario::next_tx(scenario, driver);
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        ride::end_ride(&mut rides_storage, ride_random_id, 4, test_scenario::ctx(scenario));

        test_scenario::return_shared<RidesStorage>(rides_storage);
        test_scenario::end(scenario_val);
    }
    
    // test if driver try to accept_ride when DriverNotInList
    #[test]
    #[expected_failure(abort_code=ride::EDriverNotInList)]
    fun not_listed_driver_try_to_accept_ride(){
        let admin = @0xAAAA;
        let rider = @0xBBBB;
        let driver = @0xCCCC;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        initialize(scenario, admin);
        // rider request a ride
        test_scenario::next_tx(scenario, rider);
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        let ride_id= ride::request_ride(&mut rides_storage, 14, test_scenario::ctx(scenario));

        test_scenario::return_shared<RidesStorage>(rides_storage);
        // driver try to accept the ride
        test_scenario::next_tx(scenario, driver);
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        ride::accept_ride(&mut rides_storage, ride_id, test_scenario::ctx(scenario));

        test_scenario::return_shared<RidesStorage>(rides_storage);
        test_scenario::end(scenario_val);
    }

    // test if driver with driver cap trys to accept_ride when RideDoesNotExist
    #[test]
    #[expected_failure(abort_code=ride::ERideDoesNotExist)]
    fun driver_try_to_accept_not_existed_ride(){
        let admin = @0xAAAA;
        let ride = @0xBBBB;
        let driver = @0xCCCC;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        initialize(scenario, admin);
        test_create_send_ridereadwritecap_scenario(scenario, admin, driver); // this make and send from admin to driver the RideReadWriteCap

        // driver try to accept the ride but the ride does not exist
        test_scenario::next_tx(scenario, driver);
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        ride::accept_ride(&mut rides_storage, ride, test_scenario::ctx(scenario));

        test_scenario::return_shared<RidesStorage>(rides_storage);
        test_scenario::end(scenario_val);


    }

    // test if i call is_rider_processing when RideDoesNotExist 
    #[test]
    #[expected_failure(abort_code=ride::ERiderNotInList)]
    fun call_is_rider_processing_for_not_existed_ride(){
        let admin = @0xAAAA;
        let user= @0xBBBB;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        initialize(scenario, admin);

        // check if rider is processing but he is not in list
        test_scenario::next_tx(scenario, user);
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        ride::is_rider_processing(&mut rides_storage, user);

        test_scenario::return_shared<RidesStorage>(rides_storage);
        test_scenario::end(scenario_val);
    }

    // test if i call is_driver_processing when DriverDoesNotExist
    #[test]
    #[expected_failure(abort_code=ride::EDriverNotInList)]
    fun call_is_driver_processing_for_not_existed_ride(){
        let admin = @0xAAAA;
        let user = @0xBBBB;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        initialize(scenario, admin);

        // rider request a ride
        test_scenario::next_tx(scenario, user);
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        ride::is_driver_processing(&mut rides_storage, user);

        test_scenario::return_shared<RidesStorage>(rides_storage);
        test_scenario::end(scenario_val);
    }

    // test if i call request_ride when RiderAlreadyProcessing
    #[test]
    #[expected_failure(abort_code=ride::EWrongRiderState)]
    fun call_request_ride_when_rider_already_processing(){
        let admin = @0xAAAA;
        let rider = @0xBBBB;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        initialize(scenario, admin);

        // rider request a ride
        test_scenario::next_tx(scenario, rider);
        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        ride::request_ride(&mut rides_storage, 14, test_scenario::ctx(scenario));

        test_scenario::return_shared<RidesStorage>(rides_storage);

        // rider request another ride while processing the first one
        test_scenario::next_tx(scenario, rider);

        let rides_storage = test_scenario::take_shared<RidesStorage>(scenario);
        ride::request_ride(&mut rides_storage, 25, test_scenario::ctx(scenario));

        test_scenario::return_shared<RidesStorage>(rides_storage);

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