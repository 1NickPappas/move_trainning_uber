import {
  Connection,
  Ed25519Keypair,
  JsonRpcProvider,
  RawSigner,
  fromB64,
} from "@mysten/sui.js";
import {
  SUI_NETWORK,
  ADMIN_SECRET_KEY,
  PACKAGE_ADDRESS,
  RIDES_STORAGE_ADDRESS,
} from "./config";
import { runMainFlow } from "./examples/runMainFlow"

console.log("Connecting to SUI network: ", SUI_NETWORK);

const getAdminSignerAndAddress = (provider: JsonRpcProvider) => {
  let privateKeyArray = Uint8Array.from(Array.from(fromB64(ADMIN_SECRET_KEY!)));
  const keypair = Ed25519Keypair.fromSecretKey(privateKeyArray.slice(1));
  const signer = new RawSigner(keypair, provider);
  const adminAddress = keypair.getPublicKey().toSuiAddress();

  return { adminSigner: signer, adminAddress };
};

const getRiderSignerAndAddress = (provider: JsonRpcProvider) => {
  const keypair = new Ed25519Keypair();
  const riderAddress = keypair.getPublicKey().toSuiAddress();
  const signer = new RawSigner(keypair, provider);

  return { riderSigner: signer, riderAddress };
};

const getDriverSignerAndAddress = (provider: JsonRpcProvider) => {
  const keypair = new Ed25519Keypair();
  const driverAddress = keypair.getPublicKey().toSuiAddress();
  const signer = new RawSigner(keypair, provider);

  return { driverSigner: signer, driverAddress };
};

const run = async () => {
  const connection = new Connection({
    fullnode: SUI_NETWORK,
  });
  const provider = new JsonRpcProvider(connection);
  const { adminSigner, adminAddress } = getAdminSignerAndAddress(provider);

  const { driverSigner, driverAddress } = getDriverSignerAndAddress(provider);
  const { riderSigner, riderAddress } = getRiderSignerAndAddress(provider);

  await runMainFlow({
    provider,
    ridesStorageAddress: RIDES_STORAGE_ADDRESS,
    adminSigner,
    riderSigner,
    riderAddress,
    driverSigner,
    driverAddress,
    packageId: PACKAGE_ADDRESS,
  });
};

run();
