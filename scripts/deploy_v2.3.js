const { ethers } = require("hardhat");

const OWNER             = "0xD113e4395138dB9619a5D2Ddb23B1314Dd722cb8";
const OPERATOR          = "0xD113e4395138dB9619a5D2Ddb23B1314Dd722cb8";
const ZONE_TOKEN        = "0x888AAA48EbEa87C74f690189E947d2C679705972";
const PROTOCOL_FEE_DEST = "0xD113e4395138dB9619a5D2Ddb23B1314Dd722cb8";
const WEARABLE_SIGNER   = process.env.WEARABLE_SIGNER_ADDRESS;

if (!WEARABLE_SIGNER) { console.error("❌ Missing WEARABLE_SIGNER_ADDRESS"); process.exit(1); }
if (!process.env.DEPLOYER_PRIVATE_KEY) { console.error("❌ Missing DEPLOYER_PRIVATE_KEY"); process.exit(1); }

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);
  console.log("Balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");

  console.log("\n📦 Deploying AlienzoneWearables V2.3...");
  const Factory = await ethers.getContractFactory("contracts/AlienzoneWearablesV2.3.sol:AlienzoneWearables");
  const contract = await Factory.deploy(OWNER, OPERATOR, WEARABLE_SIGNER, ZONE_TOKEN, PROTOCOL_FEE_DEST);
  await contract.waitForDeployment();
  const address = await contract.getAddress();

  console.log("\n══════════════════════════════════════════");
  console.log("✅ AlienzoneWearables V2.3 DEPLOYED");
  console.log("Address:", address);
  console.log("══════════════════════════════════════════");
  console.log("📝 Next steps:");
  console.log("  1. WEARABLES_CONTRACT_ADDRESS =", address);
  console.log("  2. WEARABLES_CONTRACT_DEPLOY_BLOCK = <current block>");
  console.log("  3. Add both V2.2 subjects to WEARABLES_EXCLUDED_SUBJECTS");
  console.log("  4. Recreate wearables via admin panel");
  console.log("  5. NEXT_PUBLIC_WEARABLES_CONTRACT_ADDRESS =", address);
}

main().catch(e => { console.error(e); process.exit(1); });
