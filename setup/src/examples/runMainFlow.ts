import { JsonRpcProvider, MIST_PER_SUI, RawSigner } from "@mysten/sui.js"
import { sendGasToRider, sendGasToDriver } from "./sendGasToActors"
import { requestRide, acceptRide, endRide } from "./rideManagement"

interface RunMainFlowProps {
  provider: JsonRpcProvider;
  ridesStorageAddress: string;
  adminSigner: RawSigner;
  riderSigner: RawSigner;
  riderAddress: string;
  driverSigner: RawSigner;
  driverAddress: string;
  packageId: string;
}

export const runMainFlow = async ({
  provider,
  ridesStorageAddress,
  adminSigner,
  riderSigner,
  riderAddress,
  driverSigner,
  driverAddress,
  packageId,
}: RunMainFlowProps) => {
  console.log("-----------------------------------------");
  console.log(
    "Running main flow for a mock rider with address:",
    riderAddress
  );
  console.log(
    "and driver with address:",
    driverAddress
  );
  console.log("Admin address:", adminSigner.getAddress());

  console.log(
    "Ride storage shared object:",
    process.env.RIDES_STORAGE_ADDRESS!
  );

  await sendGasToRider({
    signer: adminSigner,
    riderAddress,
  });
  console.log(" -> Sent gas to rider");

  await sendGasToDriver({
    signer: adminSigner,
    driverAddress,
  });
  console.log(" -> Sent gas to driver");


  const rideAddress = await requestRide({
    provider,
    ridesStorageAddress,
    riderSigner,
    riderAddress,
    packageId,
  });
  console.log(" -> Rider requested ride with id: ", rideAddress);

  const acceptedRide = await acceptRide({
    provider,
    ridesStorageAddress,
    driverSigner,
    rideAddress,
    packageId,
  });

  const endedRide = await endRide({
    provider,
    ridesStorageAddress,
    driverSigner,
    rideAddress,
    packageId,
  });
  console.log(" -> Driver ended ride with id: ", rideAddress);

  console.log("-----------------------------------------");
  console.log("Main flow finished!",);
  console.log("-----------------------------------------");

};
