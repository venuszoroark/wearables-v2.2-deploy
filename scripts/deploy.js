const { ethers } = require("hardhat");

const OWNER             = "0xD113e4395138dB9619a5D2Ddb23B1314Dd722cb8";
const OPERATOR          = "0xD113e4395138dB9619a5D2Ddb23B1314Dd722cb8";
const ZONE_TOKEN        = "0x888AAA48EbEa87C74f690189E947d2C679705972";
const PROTOCOL_FEE_DEST = "0xD113e4395138dB9619a5D2Ddb23B1314Dd722cb8";
const WEARABLE_SIGNER   = process.env.WEARABLE_SIGNER_ADDRESS;

if (!WEARABLE_SIGNER) { console.error("❌ Missing WEARABLE_SIGNER_ADDRESS"); process.exit(1); }

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);
  console.log("Balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");

  console.log("\n📦 Deploying AlienzoneWearables V2.2...");
  const Factory = await ethers.getContractFactory("AlienzoneWearables");
  const contract = await Factory.deploy(OWNER, OPERATOR, WEARABLE_SIGNER, ZONE_TOKEN, PROTOCOL_FEE_DEST);
  await contract.waitForDeployment();
  const address = await contract.getAddress();

  console.log("══════════════════════════════════════════");
  console.log("✅ AlienzoneWearables V2.2 DEPLOYED");
  console.log("Address:", address);
  console.log("══════════════════════════════════════════");
  console.log("⚠️  UPDATE backend WEARABLES_ARBITRUM =", address);
}

main().catch(e => { console.error(e); process.exit(1); });
