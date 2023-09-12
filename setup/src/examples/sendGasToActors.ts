import { RawSigner, TransactionBlock } from "@mysten/sui.js"

interface SendGasToRiderProps {
  signer: RawSigner;
  riderAddress: string;
}

export const sendGasToRider = async ({
  signer,
  riderAddress,
}: SendGasToRiderProps) => {
  const tx = new TransactionBlock();
  let coin = tx.splitCoins(tx.gas, [tx.pure(2000000000)]);
  tx.transferObjects([coin], tx.pure(riderAddress));
  await signer.signAndExecuteTransactionBlock({
    transactionBlock: tx,
  });
};

interface SendGasToDriverProps {
  signer: RawSigner;
  driverAddress: string;
}

export const sendGasToDriver = async ({
  signer,
  driverAddress,
}: SendGasToDriverProps) => {
  const tx = new TransactionBlock();
  let coin = tx.splitCoins(tx.gas, [tx.pure(2000000000)]);
  tx.transferObjects([coin], tx.pure(driverAddress));
  await signer.signAndExecuteTransactionBlock({
    transactionBlock: tx,
  });
};
