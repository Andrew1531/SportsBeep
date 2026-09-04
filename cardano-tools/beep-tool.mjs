#!/usr/bin/env node
// Cardano transaction tool for SportsBeep on-chain $BEEP transfers.
// Commands (all print a single JSON object to stdout):
//   address                          -> derive treasury address from TREASURY_MNEMONIC
//   find-unit <bech32Address>        -> find the $BEEP asset unit held by an address
//   build-deposit <userAddr> <treasuryAddr> <unit> <amount>
//                                    -> build an unsigned tx sending <amount> of <unit>
//                                       from the user's UTxOs to the treasury
//   build-payout <toAddr> <unit> <amount>
//                                    -> build/sign treasury payout and print its hash
//   submit-payout <signedTx>         -> submit a previously signed treasury payout
import { BlockfrostProvider, MeshWallet, MeshTxBuilder, resolveTxHash } from "@meshsdk/core";

const projectId = process.env.BLOCKFROST_PROJECT_ID;
const out = (obj) => { console.log(JSON.stringify(obj)); };
const fail = (error) => { out({ ok: false, error: String(error && error.message ? error.message : error) }); process.exit(1); };

if (!projectId) fail("BLOCKFROST_PROJECT_ID is not set");
const provider = new BlockfrostProvider(projectId);

function treasuryWallet() {
  const mnemonic = (process.env.TREASURY_MNEMONIC || "").trim();
  if (!mnemonic) throw new Error("TREASURY_MNEMONIC is not set");
  return new MeshWallet({
    networkId: 1,
    fetcher: provider,
    submitter: provider,
    key: { type: "mnemonic", words: mnemonic.split(/\s+/) },
  });
}

// STRICT matching only: on-chain money movement must never rely on fuzzy
// name matching, or a look-alike token could be spoofed as $BEEP.
function isBeepUnit(unit) {
  const expected = (process.env.BEEP_ASSET_UNIT || "").trim();
  if (!expected) throw new Error("BEEP_ASSET_UNIT is required for on-chain transfers");
  return unit === expected;
}

async function findUnit(address) {
  const utxos = await provider.fetchAddressUTxOs(address);
  const totals = new Map();
  for (const u of utxos) {
    for (const a of u.output.amount) {
      if (a.unit === "lovelace") continue;
      totals.set(a.unit, (totals.get(a.unit) || 0n) + BigInt(a.quantity));
    }
  }
  for (const [unit, qty] of totals) {
    if (isBeepUnit(unit)) return { unit, quantity: qty.toString() };
  }
  return null;
}

const [cmd, ...args] = process.argv.slice(2);

try {
  if (cmd === "address") {
    const wallet = treasuryWallet();
    const addr = await wallet.getChangeAddress();
    out({ ok: true, address: addr });
  } else if (cmd === "find-unit") {
    const [address] = args;
    if (!address) throw new Error("usage: find-unit <address>");
    const found = await findUnit(address);
    if (found) {
      out({ ok: true, ...found });
    } else {
      out({ ok: false, error: "No $BEEP tokens found at this address" });
      process.exit(1);
    }
  } else if (cmd === "build-deposit") {
    const [userAddr, treasuryAddr, unit, amount] = args;
    if (!userAddr || !treasuryAddr || !unit || !amount) throw new Error("usage: build-deposit <userAddr> <treasuryAddr> <unit> <amount>");
    if (!isBeepUnit(unit)) throw new Error("Refusing deposit: unit does not match BEEP_ASSET_UNIT");
    const utxos = await provider.fetchAddressUTxOs(userAddr);
    if (!utxos.length) throw new Error("No UTxOs found at the user's address");
    const txBuilder = new MeshTxBuilder({ fetcher: provider });
    const unsignedTx = await txBuilder
      .txOut(treasuryAddr, [{ unit, quantity: String(amount) }])
      .changeAddress(userAddr)
      .selectUtxosFrom(utxos)
      .complete();
    out({ ok: true, unsigned_tx: unsignedTx });
  } else if (cmd === "build-payout") {
    const [toAddr, unit, amount] = args;
    if (!toAddr || !unit || !amount) throw new Error("usage: build-payout <toAddr> <unit> <amount>");
    const wallet = treasuryWallet();
    const changeAddr = await wallet.getChangeAddress();
    const utxos = await wallet.getUtxos();
    if (!utxos.length) throw new Error("Treasury wallet has no UTxOs (needs ADA for fees)");
    if (!isBeepUnit(unit)) throw new Error("Refusing payout: unit does not match BEEP_ASSET_UNIT");
    try {
      const txBuilder = new MeshTxBuilder({ fetcher: provider });
      const unsignedTx = await txBuilder
        .txOut(toAddr, [{ unit, quantity: String(amount) }])
        .changeAddress(changeAddr)
        .selectUtxosFrom(utxos)
        .complete();
      const signedTx = await wallet.signTx(unsignedTx);
      const txHash = resolveTxHash(signedTx);
      out({ ok: true, signed_tx: signedTx, tx_hash: txHash });
    } catch (e) {
      // Failure BEFORE submission — definitely not on-chain, safe to refund.
      out({ ok: false, stage: "build", error: String(e && e.message ? e.message : e) });
      process.exit(1);
    }
  } else if (cmd === "submit-payout") {
    const [signedTx] = args;
    if (!signedTx) throw new Error("usage: submit-payout <signedTx>");
    const txHash = resolveTxHash(signedTx);
    try {
      const submittedHash = await provider.submitTx(signedTx);
      if (submittedHash !== txHash) throw new Error("Submitted transaction hash did not match the signed transaction");
      out({ ok: true, tx_hash: submittedHash });
    } catch (e) {
      // Failure DURING submission — the tx may or may not have reached the
      // network. Callers must NOT refund automatically.
      out({ ok: false, stage: "submit", tx_hash: txHash, error: String(e && e.message ? e.message : e) });
      process.exit(1);
    }
  } else {
    throw new Error(`unknown command: ${cmd}`);
  }
} catch (e) {
  fail(e);
}
