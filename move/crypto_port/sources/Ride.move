module crypto_port::ride {

    
    // use std::string::String;
    use std::option::{Self, Option};
    use sui::event::{Self};
    

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    use sui::table::{Self, Table};
    // use std::string;
    // use sui::object_table::{Self, ObjectTable};

    //Consts ******************************************************
    // ************************************************************

    // Error types//
    const EEmptyInventory: u64 = 0; // this is for the empty inventory
    const EWrongDriverState: u64 = 1; // this is for the wrong driver state
    const EWrongRiderState: u64 = 2;// this is for the wrong rider state
    const ERideDoesNotExist: u64 = 3; // this is for the ride does not exist
    /// Is this the driver at this ride
    const EDriverAtRide: u64 = 4; // this is for the driver at other ride
    const EDriverNotAtRide: u64 = 5; // this is for the driver not at ride

    const EDriverNotInList: u64 = 6; // this is for the driver not in the driver list
    const ERiderNotInList: u64 = 7; // this is for the rider not in the rider list
    ////////////////////////////////////////

    const StateAccepted: u16 = 2; // this is for the accepted state
    const StateCompleted: u16 = 6; // this is for the completed state
    const StateCancelled: u16 = 2; // this is for the cancelled state
    const StatePending: u16 = 3; // this is for the pending state
    /////////////////////////////////////////
    /// /// RiderStateAvailable is when the rider is not in a ride
    const DriverStateAvailable: bool = false; // this is for the driver available
    const DriverStateProcessing: bool = true; // this is for the driver processing a ride
    //////////////////////////////////////////
    const RiderStateAvailable: bool = false; // this is for the rider available
    const RiderStateProcessing: bool = true; // this is for the rider processing a ride
    /// 
    /// Driver status is active or inactive depends on the admin if want to activate or deactivate the driver
    const DriverStatusActive: u16 = 0; // this is for the driver active
    const DriverStatusInactive: u16 = 1; // this is for the driver inactive






    //**************************************************************
    //**************************************************************

    

    // this is for partner (the publisher )
    struct AdminCap has key,store{
        id: UID,

    }

    // this is only for the driver.. i will use it as driver cap 
    struct RideReadWriteCap has key ,store {
        id: UID,
        //status can be active or inactive=> 1 or 0
        status: u16,


    }


    struct Ride has  key,store {
        id: UID, // i dont know if this is nessesary
        estimate_distance: u64,
        actual_distance: Option<Actual_distance>,
        ride_state: Option<State>,// this is for the state of the ride
        rider_address: address, // this is for the rider that is processing the ride
        driver_address: option::Option<address>, // this is for the driver that is processing the ride
        
    }


    // this is the storage that will be shared
    struct RidesStorage has key,store{
        id: UID,
        // estimate_distance: u64,
        // actual_distance: Option<Actual_distance>,
        rider_id: Table<address,Rider>,
        rider_complete_rides: Table<address,u64>, //this is 0 or 1 if the rider is processing a ride or not
        driver_id: Table<address,Driver>, //this is 0 or 1 if the driver is processing a ride or not
        // ride_state: Table<address,State>, //
        rides: Table<address,Ride>


    }


    // 

    struct Driver has store{
        
        driver_processing: bool, // False if the driver is not processing a ride and true if he is processing a ride
        
        
    }

    struct Rider has copy,store{
        rider_processing: bool, // False if the rider is not processing a ride and true if he is processing a ride
        complete_rides_num: u64, // the number of completed rides
    }


    // i will use this to change the status at the RidesStorage
    struct State has store ,copy,drop {
        value: u16, // 0 for accepted , 1 for completed , 2 for cancelled
    }

    // i will use this to change the actual distance at the RidesStorage
    struct Actual_distance has store ,copy,drop {
        value: u64,
    }

    // this is for the ride request EVENT
    struct Ride_Request has copy, drop {
        ride_adr: address,
    }

    //********************************************
    //********************************************

    // init function will called at the publish and will send the admin cap to the publisher
    // and will create the nessesary tables
    // and will create the RidesStorage and will share it
    fun init(ctx: &mut TxContext) {
        // this is for send admin cap to send them at the publisher
        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::public_transfer(admin_cap, tx_context::sender(ctx));
        ///////////////////////////////////////////////////////////////
        let ride_read_write_cap= RideReadWriteCap {
            id: object::new(ctx),
            status: DriverStatusActive,
        };
        transfer::public_transfer(ride_read_write_cap, tx_context::sender(ctx));
        ///////////////////////////////////////////////////////////////
        
        let info= RidesStorage{
            id: object::new(ctx),
            rider_complete_rides: table::new<address,u64>(ctx),

            //rider_id will be the tx sender
            rider_id: table::new<address,Rider>(ctx),
            // dricer_id and state will be none
            driver_id: table::new<address,Driver>(ctx),
            // ride_state: ride_state,

            //ommmm i will see what is this
            rides : table::new<address,Ride>(ctx),           
        };
  

        transfer::share_object(info);
        
        

    }    

    ///////////////////////////////////////////////////////////////////////////////////
    /// Functions 
    ///////////////////////////////////////////////////////////////////////////////////


    // create a new driver and send it to the driver .. only the admin can do this
    public fun create_driver(_:&AdminCap ,ctx: &mut TxContext): RideReadWriteCap {
        let driver = RideReadWriteCap {
            id: object::new(ctx),
            status: DriverStatusActive,
        };
        driver
    }
     // @todo = rename this fun
    // this function will be called by the admin to send the driver cap to the incoming driver
    public fun send_driver_cap(_: &AdminCap,info: &mut RidesStorage,driver_cap: RideReadWriteCap, recipient: address) {
        transfer::public_transfer(driver_cap, recipient);
        // add driver to the driver list
        table::add(&mut info.driver_id,recipient,Driver{driver_processing: DriverStateAvailable});
    }

    ///////////////////////////////////////////////////////////////////////////////////
    


    // the Rider will request a ride
    //need to remake this function
    public fun request_ride(
        info: &mut RidesStorage,
        // actual_distance: u64,  maybe not need this but crash my test code
        estimate_distance: u64,
        ctx: &mut TxContext): address
    {
        // i will check if the rider address is in the rider_id table
        // ifit is not i drop error with assert
        // and if it is in i will check if the rider is processing a ride
        if (table::contains(&info.rider_id,tx_context::sender(ctx))){
            assert!(table::borrow(&info.rider_id,tx_context::sender(ctx)).rider_processing != RiderStateProcessing, EWrongRiderState);
            //change the rider state to processing
            let rider = table::borrow_mut(&mut info.rider_id,tx_context::sender(ctx));
            rider.rider_processing = RiderStateProcessing;
            // check if the rider is processing a ride
            //@todo = need to uncomment the next line
            assert!(table::borrow(&info.rider_id,tx_context::sender(ctx)).rider_processing == RiderStateProcessing, EWrongRiderState);

        }
        else{
            // insert the rider to the rider_id table if was first time
            table::add(&mut info.rider_id,tx_context::sender(ctx),Rider{rider_processing: RiderStateProcessing,complete_rides_num: 0});
        };
    

        //add the ride to the rides list
        let ride = Ride{
            id: object::new(ctx),
            // estimate distance will be the distance that the rider will give
            estimate_distance: estimate_distance,
            // actual_distance will be none
            actual_distance: option::none<Actual_distance>(),
            //ride_state will be pending
            ride_state: option::some(State{value: StatePending}),
            // rider_address will be the tx sender
            rider_address: tx_context::sender(ctx),
            // driver_address will be none until the driver accept the ride
            driver_address: option::none<address>(),
        };
        
        //get the address of the ride
        let ride_adr = object::id_address(&ride);

        event::emit(Ride_Request { ride_adr: ride_adr });

        //insert the new ride to the rides list
        table::add(&mut info.rides, ride_adr, ride);

        // change rider state to processing
        table::borrow_mut(&mut info.rider_id,tx_context::sender(ctx)).rider_processing = RiderStateProcessing;

        // return the address of the ride
        ride_adr
    }

    // read the rides list
    public fun get_rides(info: &RidesStorage):&Table<address,Ride>{
        &info.rides   
    }
        
    

    // this function return if the rider is processing a ride or not , 
    //true if he is processing a ride and false if he is not processing a ride                
    public fun is_rider_processing(infos: &RidesStorage,rider : address):bool{

        assert!(table::contains(&infos.rider_id,rider),ERiderNotInList); // check if the rider list is empty
        let rider_proc = table::borrow(&infos.rider_id,rider);
        rider_proc.rider_processing

    }

    // this function return if the driver is processing a ride or not ,
    // true if he is processing a ride and false if he is not processing a ride            
    public fun is_driver_processing(infos:&mut RidesStorage,driver : address):bool{

        assert!(table::contains(&infos.driver_id,driver),EDriverNotInList); // check if the driver list is empty
        let driver_proc = table::borrow(&infos.driver_id,driver);
        driver_proc.driver_processing

    }

   

    
    // this function is for the driver to accept the ride
    public fun accept_ride(infos: &mut RidesStorage,ride_id : address,ctx: &mut TxContext){
        assert!(table::contains(&infos.driver_id,tx_context::sender(ctx)),EDriverNotInList); // check if the driver list is empty

        assert!(table::contains(&infos.rides,ride_id),ERideDoesNotExist); // check if the ride list is empty
        
        // add at ride the driver address
        table::borrow_mut(&mut infos.rides,ride_id).driver_address = option::some(tx_context::sender(ctx));
        let ride = table::borrow_mut(&mut infos.rides,ride_id) ;
        let ride_state = option::borrow_mut(&mut ride.ride_state);
        ride_state.value = StateAccepted;

        //change the driver state to processing
        table::borrow_mut(&mut infos.driver_id,tx_context::sender(ctx)).driver_processing = DriverStateProcessing;
        

        //change the rider state to processing
        table::borrow_mut(&mut infos.rider_id,ride.rider_address).rider_processing = RiderStateProcessing;     

    }

    // this function return the state of the ride   
    public fun get_ride_state(infos: &RidesStorage,ride_id: address): u16{
        // here maybe need to check if the ride address is in the rides list (later)
        let ride = table::borrow(&infos.rides,ride_id);
        let state = option::borrow(&ride.ride_state);
        state.value

        
    }

     public fun end_ride(infos: &mut RidesStorage,ride_address: address,actual_distance: u64,ctx: &mut TxContext){
        
        assert!(table::contains(&infos.driver_id,tx_context::sender(ctx)),EDriverNotInList); // check if the driver list is empty
        assert!(table::contains(&infos.rides,ride_address),ERideDoesNotExist); //check if the driver is in the driver list and if the ride is in the rides list
        //check if the sender was the driver at this ride
        assert!(table::borrow(&infos.rides,ride_address).driver_address == option::some(tx_context::sender(ctx)), EDriverNotAtRide);
        

        //change the state to completed
        let ride = table::borrow_mut(&mut infos.rides,ride_address) ;
        let ride_rider_address = ride.rider_address;
        let ride_state = option::borrow_mut(&mut ride.ride_state);
        ride_state.value = StateCompleted;
    
        //change the driver state to available
        table::borrow_mut(&mut infos.driver_id,tx_context::sender(ctx)).driver_processing = DriverStateAvailable;
        
        //change the actual_distance
        table::borrow_mut(&mut infos.rides,ride_address).actual_distance = option::some(Actual_distance{value: actual_distance});

        //change the rider state to available
        table::borrow_mut(&mut infos.rider_id,ride_rider_address).rider_processing = RiderStateAvailable;
        // counter completed rides at rider
        //table::borrow_mut(&mut infos.rider_id,ride_rider_address).complete_rides_num = table::borrow(&infos.rider_id,ride_rider_address).complete_rides_num + 1;
        // };

        }
        

    #[test_only]
    public entry fun test_init(ctx: &mut TxContext) {
        init(ctx)
    }

}
