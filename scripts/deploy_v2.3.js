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

  console.log("\n📦 Deploying AlienzoneWearables V2.3...");
  const Factory = await ethers.getContractFactory("AlienzoneWearablesV2.3");
  const contract = await Factory.deploy(OWNER);
  await contract.waitForDeployment();
  const address = await contract.getAddress();
  console.log("Contract deployed to:", address);

  console.log("\n⚙️  Initializing...");
  const tx = await contract.initialize(OPERATOR, WEARABLE_SIGNER, ZONE_TOKEN, PROTOCOL_FEE_DEST);
  await tx.wait();
  console.log("Initialized ✅");

  console.log("\n══════════════════════════════════════════");
  console.log("✅ AlienzoneWearables V2.3 DEPLOYED");
  console.log("Address:", address);
  console.log("══════════════════════════════════════════");
  console.log("📝 Next steps:");
  console.log("  1. Update backend: WEARABLES_CONTRACT_ADDRESS =", address);
  console.log("  2. Update backend: WEARABLES_CONTRACT_DEPLOY_BLOCK = <block number>");
  console.log("  3. Update backend: WEARABLES_EXCLUDED_SUBJECTS = (add both V2.2 subjects)");
  console.log("  4. Recreate wearables on new contract via admin panel");
  console.log("  5. Update frontend: NEXT_PUBLIC_WEARABLES_CONTRACT_ADDRESS =", address);
}

main().catch(e => { console.error(e); process.exit(1); });
