const { ethers } = require("hardhat");

// ── CONFIG ────────────────────────────────────────────────────────────────────
const OWNER              = "0xD113e4395138dB9619a5D2Ddb23B1314Dd722cb8"; // PROTOCOL_WALLET
const OPERATOR           = "0xD113e4395138dB9619a5D2Ddb23B1314Dd722cb8"; // wearableOperator
const ZONE_TOKEN         = "0x888AAA48EbEa87C74f690189E947d2C679705972"; // ZONE token
const PROTOCOL_FEE_DEST  = "0xD113e4395138dB9619a5D2Ddb23B1314Dd722cb8"; // fee destination
// WEARABLE_SIGNER: loaded from env (set on EC2 in .env as WEARABLE_SIGNER_ADDRESS)
const WEARABLE_SIGNER    = process.env.WEARABLE_SIGNER_ADDRESS;

if (!WEARABLE_SIGNER) {
  console.error("❌ Missing WEARABLE_SIGNER_ADDRESS env variable");
  process.exit(1);
}

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);
  console.log("Balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");

  // 1. Deploy implementation
  console.log("\n📦 Deploying AlienzoneWearables V2.2...");
  const Factory = await ethers.getContractFactory("AlienzoneWearables");
  const contract = await Factory.deploy(OWNER);
  await contract.waitForDeployment();
  const address = await contract.getAddress();
  console.log("✅ Deployed at:", address);

  // 2. Initialize
  console.log("\n🔧 Initializing...");
  const tx = await contract.initialize(
    OPERATOR,
    WEARABLE_SIGNER,
    ZONE_TOKEN,
    PROTOCOL_FEE_DEST
  );
  await tx.wait();
  console.log("✅ Initialized");

  // 3. Print summary
  console.log("\n══════════════════════════════════════════");
  console.log("AlienzoneWearables V2.2 DEPLOYED");
  console.log("Address:         ", address);
  console.log("Owner:           ", OWNER);
  console.log("Operator:        ", OPERATOR);
  console.log("Signer:          ", WEARABLE_SIGNER);
  console.log("Zone Token:      ", ZONE_TOKEN);
  console.log("Protocol Fee:    ", PROTOCOL_FEE_DEST);
  console.log("══════════════════════════════════════════");
  console.log("\n⚠️  UPDATE backend: WEARABLES_ARBITRUM =", address);
  console.log("⚠️  UPDATE .env on EC2: add this address");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
