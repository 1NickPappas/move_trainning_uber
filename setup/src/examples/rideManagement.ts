import {
    JsonRpcProvider,
    RawSigner,
    TransactionBlock,
} from "@mysten/sui.js";

let totalGasCost = 0;

interface RequestRideProps {
    provider: JsonRpcProvider;
    ridesStorageAddress: string;
    riderSigner: RawSigner;
    riderAddress: string;
    packageId: string;
}

export const requestRide = async ({
    provider,
    ridesStorageAddress,
    riderSigner,
    riderAddress,
    packageId,
}: RequestRideProps): Promise<string> => {

    // TODO: Implement here
};

interface AcceptRideProps {
    provider: JsonRpcProvider;
    ridesStorageAddress: string;
    driverSigner: RawSigner;
    rideAddress: string;
    packageId: string;
}

export const acceptRide = async ({
    provider,
    ridesStorageAddress,
    driverSigner,
    rideAddress,
    packageId,
}: AcceptRideProps): Promise<string> => {

    // TODO: Implement here
};

interface EndRideProps {
    provider: JsonRpcProvider;
    ridesStorageAddress: string;
    driverSigner: RawSigner;
    rideAddress: string;
    packageId: string;
}

export const endRide = async ({
    provider,
    ridesStorageAddress,
    driverSigner,
    rideAddress,
    packageId,
}: EndRideProps): Promise<string> => {

    // TODO: Implement here

};
