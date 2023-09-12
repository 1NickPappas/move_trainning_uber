module crypto_port::ride {

    
    // use std::string::String;
    use std::option::{Self, Option};

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    use sui::table::{Self, Table};
    // use std::string;

    // use sui::object_table::{Self, ObjectTable};

    //Consts ******************************************************
    // ************************************************************

    // Error types//
    const EEmptyInventory: u64 = 0;
    const EWrongDriverState: u64 = 1;
    const EWrongRiderState: u64 = 2;
    const ERideDoesNotExist: u64 = 3;
    ////////////////////////////////////////

    const StateAccepted: u16 = 2;
    const StateCompleted: u16 = 6;
    const StateCancelled: u16 = 2;
    const StatePending: u16 = 3;
    /////////////////////////////////////////
    /// /// RiderStateAvailable is when the rider is not in a ride
    const DriverStateAvailable: bool = false;
    const DriverStateProcessing: bool = true;
    //////////////////////////////////////////
    const RiderStateAvailable: bool = false;
    const RiderStateProcessing: bool = true;
    /// 
    /// Driver status is active or inactive depends on the admin if want to activate or deactivate the driver
    const DriverStatusActive: u16 = 0;
    const DriverStatusInactive: u16 = 1;

    ///
    /// Is this the driver at this ride
    const EDriverAtRide: u64 = 0;
    const EDriverNotAtRide: u64 = 1;

    const EDriverNotInList: u64 = 0;



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


    //na valw ride
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


    // for opt *********************************

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
    // Status will be used to change the status of the driver and the rider
    // struct Status has store ,copy,drop {
    //     _value: u16, //
    // }

    struct Actual_distance has store ,copy,drop {
        value: u64,
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

    public fun send_driver_cap(_: &AdminCap,driver_cap : RideReadWriteCap, recipient: address) {
        transfer::public_transfer(driver_cap, recipient);
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
        // check if rider is in rider list
        // assert!(!table::contains(&info.rider_id,tx_context::sender(ctx)), ERideDoesNotExist);
        //check if the rider is processing another ride
        // assert!(table::borrow(&info.rider_id,tx_context::sender(ctx)).rider_processing == RiderStateProcessing, EWrongRiderState);
        
        // i will check if the rider address is in the rider_id table
        // ifit is not i drop error with assert
        // and if it is in i will check if the rider is processing a ride
        if (table::contains(&info.rider_id,tx_context::sender(ctx))){
            assert!(table::borrow(&info.rider_id,tx_context::sender(ctx)).rider_processing != RiderStateProcessing, EWrongRiderState);
            //change the rider state to processing
            let rider = table::borrow_mut(&mut info.rider_id,tx_context::sender(ctx));
            rider.rider_processing = RiderStateProcessing;
            assert!(table::borrow(&info.rider_id,tx_context::sender(ctx)).rider_processing == RiderStateProcessing, EWrongRiderState);

        }
        else{
            // insert the rider to the rider_id table if was first time
            table::add(&mut info.rider_id,tx_context::sender(ctx),Rider{rider_processing: RiderStateProcessing,complete_rides_num: 0});
        };
    

        //add the ride to the rides list
        let ride = Ride{
            id: object::new(ctx),
            estimate_distance: estimate_distance,
            actual_distance: option::none<Actual_distance>(),
            //ride_state will be pending
            ride_state: option::some(State{value: StatePending}),
            rider_address: tx_context::sender(ctx),
            driver_address: option::none<address>(),
        };
        
        //get the address of the ride
        let ride_adr = object::id_address(&ride);

        //insert the new ride to the rides list
        table::add(&mut info.rides, ride_adr, ride);
        ride_adr
    }

    //need to be called by the driver  **maybe its done**
    public fun get_rides(info: &RidesStorage):&Table<address,Ride>{
        &info.rides   
    }
        
    

    // normaly this will return if the driver is processing a ride or not                 **maybe its done**
    public fun is_rider_processing(infos: &RidesStorage,rider : address):bool{

        if (table::contains(&infos.rider_id,rider)){
            let rider_proc = table::borrow(&infos.rider_id,rider);
            rider_proc.rider_processing
        }
        else{
            false
        }
    

    }

    // normaly this will return if the driver is processing a ride or not             **maybe its done**
    public fun is_driver_processing(infos:&mut RidesStorage,driver : address):bool{
        //check if the driver list is empty
          // return the driver_processing
        if (table::contains(&infos.driver_id,driver)){
            let driver_proc = table::borrow(&infos.driver_id,driver);
            driver_proc.driver_processing
        }
        else{
            false
        }



    }

   

    
    // this function is for the driver to accept the ride
    public fun accept_ride(infos: &mut RidesStorage,ride_id : address,ctx: &mut TxContext){

        //check if the driver is processing another ride
        // assert!(table::borrow(&infos.driver_id,tx_context::sender(ctx)).driver_processing == DriverStateProcessing, EWrongDriverState);
        if (table::contains(&infos.driver_id,tx_context::sender(ctx))){
            assert!(table::borrow(&infos.driver_id,tx_context::sender(ctx)).driver_processing != DriverStateProcessing, EWrongDriverState);
        }
        else{
            // insert the driver to the driver_id table if was first time
            table::add(&mut infos.driver_id,tx_context::sender(ctx),Driver{driver_processing: DriverStateProcessing});
        };

        if (table::contains( &infos.rides,ride_id) && table::contains(&infos.driver_id,tx_context::sender(ctx))){
                    //change state to ""ACCEPTED""//
            let ride = table::borrow_mut(&mut infos.rides,ride_id) ;
            let ride_state = option::borrow_mut(&mut ride.ride_state);
            ride_state.value = StateAccepted;

            //change the driver state to processing
            table::borrow_mut(&mut infos.driver_id,tx_context::sender(ctx)).driver_processing = DriverStateProcessing;
            

            //change the rider state to processing
            table::borrow_mut(&mut infos.rider_id,ride.rider_address).rider_processing = RiderStateProcessing;     
        }   


 
    }

    // check the state of the ride    **maybe its done**
    public fun get_ride_state(infos: &RidesStorage,ride_id: address): u16{
        //get the state of the ride
        let ride = table::borrow(&infos.rides,ride_id);
        let state = option::borrow(&ride.ride_state);
        state.value

        
    }
    

    
    // this function is for the driver to complete the ride  **maybe its done**
    public fun end_ride(infos: &mut RidesStorage,ride_address: address,actual_distance: u64,ctx: &mut TxContext){
        //check if the driver is processing another ride
        if(table::contains(&infos.driver_id,tx_context::sender(ctx)) && table::contains(&infos.rides,ride_address)){
            //check if the sender was the driver at this ride
            assert!(table::borrow(&infos.rides,ride_address).driver_address != option::some(tx_context::sender(ctx)), EDriverNotAtRide);

            //change the state to completed
            let ride = table::borrow_mut(&mut infos.rides,ride_address) ;
            let ride_rider_address = ride.rider_address;
            let ride_state = option::borrow_mut(&mut ride.ride_state);
            ride_state.value = StateCompleted;
        
            //change the driver state to available
            table::borrow_mut(&mut infos.driver_id,tx_context::sender(ctx)).driver_processing = DriverStateAvailable;
            
            //change the actual_distance
            table::borrow_mut(&mut infos.rides,ride_address).actual_distance = option::some(Actual_distance{value: actual_distance});
            
            

            if(table::contains(&infos.rider_id,ride_rider_address)){
                //change the rider state to available
                table::borrow_mut(&mut infos.rider_id,ride_rider_address).rider_processing = RiderStateAvailable;
                // counter completed rides at rider
                table::borrow_mut(&mut infos.rider_id,ride_rider_address).complete_rides_num = table::borrow(&infos.rider_id,ride_rider_address).complete_rides_num + 1;
            };

 
            

        };
        

        
        


    }

    

    


    #[test_only]
    public entry fun test_init(ctx: &mut TxContext) {
        init(ctx)
    }

}
