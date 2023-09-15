import { config } from "dotenv";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { SuiClient, getFullnodeUrl } from "@mysten/sui.js/client";
import { TransactionBlock } from "@mysten/sui.js/transactions";
// import{} from "@mysten/sui.js/";
config();
// let driver= "0x024dfa97074cadf9650ec4f5d9e1c21348c8223ba30be50bcf6861e0b848f5f0"
async function mint_sent_driver_cap(driver: string) {
  let client = new SuiClient({ url: getFullnodeUrl("testnet") });
  let keypair = Ed25519Keypair.deriveKeypair(
    process.env.MNEMONIC_PHRASE as string
  );
  console.log("Keypair-> ADMIN", keypair.toSuiAddress().toString());
  // let driver= "0x024dfa97074cadf9650ec4f5d9e1c21348c8223ba30be50bcf6861e0b848f5f0"
  // let driver = Ed25519Keypair.deriveKeypair(
  //   process.env.MNEMONIC_PHRASE_DRIVER as string
  // );



  let tx = new TransactionBlock();

  let driver_cap =tx.moveCall({
    target: `${process.env.PACKAGE_ID}::ride::create_driver`,
    arguments: [
      tx.object(
        process.env.ADMIN_CAP_ID as string
      ),
    ],
  });


  // send driver cap
tx.transferObjects([driver_cap], tx.pure(`${process.env.ADMIN_ADR}`));


const result = await client.signAndExecuteTransactionBlock({
    transactionBlock: tx,
    signer: keypair,
    options: {
      showEffects: true,
    },
  });

  console.log("Execution status", result.effects?.status);
  console.log("Result", result.effects);


}

async function add_driver_to_list(driver: string) {

  let client = new SuiClient({ url: getFullnodeUrl("testnet") });
  let keypair = Ed25519Keypair.deriveKeypair(
    process.env.MNEMONIC_PHRASE as string
  );
  console.log("Keypair-> ADMIN", keypair.toSuiAddress().toString());

  let tx = new TransactionBlock();
  
  let add_driver_to_list =tx.moveCall({
  target: `${process.env.PACKAGE_ID}::ride::send_driver_cap`,
  arguments: [
    tx.object(
      process.env.ADMIN_CAP_ID as string
    ),
    tx.object(
      process.env.RIDESTORAGE_ID as string
    ),
    tx.object(
      process.env.DRIVER_CAP_ID as string
    ),
    tx.pure(`${process.env.DRIVER_ADR}`),
  ],
});

const result = await client.signAndExecuteTransactionBlock({
    transactionBlock: tx,
    signer: keypair,
    options: {
      showEffects: true,
    },
  });

  console.log("Execution status", result.effects?.status);
  console.log("Result", result.effects);


};
//i want to Rider requests Ride, Driver accepts ride and completes it
//function that takes a Rider and request ride

async function requestRide(estimate_distance: number): Promise<string | undefined> {
  let client = new SuiClient({ url: getFullnodeUrl("testnet") });
  let keypair = Ed25519Keypair.deriveKeypair(
    process.env.MNEMONIC_PHRASE_RIDER as string
  );
  console.log("Keypair->RIDER", keypair.toSuiAddress().toString());


  let tx = new TransactionBlock();

  let request_ridee =tx.moveCall({
    target: `${process.env.PACKAGE_ID}::ride::request_ride`,
    arguments: [
      tx.object(
        process.env.RIDESTORAGE_ID as string,
        
        
      ),
      tx.pure(estimate_distance),
    ],
  });
  // console.log("request ride", request_ridee);


  
  const result = await client.signAndExecuteTransactionBlock({
    transactionBlock: tx,
    signer: keypair,
    options: {
      showEffects: true,
      showEvents: true,
    },
  });

  console.log("Execution status", result.effects?.status);
  console.log("Result", result.effects);
  console.log("Events", result.events);
  // return result.events?.filter((event) => event.type === "string")[0].data;
  let events: any = result.events?.find((event) => event.type === `${process.env.PACKAGE_ID}::ride::Ride_Request`);
  let ride_id: string= events?.parsedJson?.ride_adr;
  console.log("ride id", ride_id);
  return ride_id;
};

async function acceptRide(ride_id: string){
  let client = new SuiClient({ url: getFullnodeUrl("testnet") });
  let keypair = Ed25519Keypair.deriveKeypair(
    process.env.MNEMONIC_PHRASE_DRIVER as string
  );
  console.log("Keypair->DRIVER", keypair.toSuiAddress().toString());
  
  let tx = new TransactionBlock();
  let accept_ridee =tx.moveCall({
    target: `${process.env.PACKAGE_ID}::ride::accept_ride`,
    arguments: [
      tx.object(
        process.env.RIDESTORAGE_ID as string,
        
        
      ),
      tx.pure(ride_id),
    ],
  });

  const result = await client.signAndExecuteTransactionBlock({
    transactionBlock: tx,
    signer: keypair,
    options: {
      showEffects: true,
    },
  });

  console.log("Execution status", result.effects?.status);
  console.log("Result", result.effects);



};

async function completeRide(ride_id: string , actual_distance: number){
  let client = new SuiClient({ url: getFullnodeUrl("testnet") });
  let keypair = Ed25519Keypair.deriveKeypair(
    process.env.MNEMONIC_PHRASE_DRIVER as string
  );
  console.log("Keypair", keypair.toSuiAddress().toString());

  let tx = new TransactionBlock();

  let complete_ridee =tx.moveCall({
    target: `${process.env.PACKAGE_ID}::ride::end_ride`,
    arguments: [
      tx.object(
        process.env.RIDESTORAGE_ID as string,
        
        
      ),
      tx.pure(ride_id),
      tx.pure(actual_distance),
    ],
  });

  const result = await client.signAndExecuteTransactionBlock({
    transactionBlock: tx,
    signer: keypair,
    options: {
      showEffects: true,
    },
  });

  console.log("Execution status", result.effects?.status);
  console.log("Result", result.effects);

};





async function main() {
  await mint_sent_driver_cap(process.env.DRIVER_ADR as string);
  await add_driver_to_list(process.env.DRIVER_ADR as string);
  let ride_id= await requestRide(10);
  await acceptRide(ride_id as string);
  await completeRide(ride_id as string, 10);
}

main();
// acceptRide(ride_id);
