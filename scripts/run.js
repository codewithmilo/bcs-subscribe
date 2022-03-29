async function main() {
  const prices = [
    hre.ethers.utils.parseEther("0.1"), // LIFE
    hre.ethers.utils.parseEther("0.001"), // WEEK
    hre.ethers.utils.parseEther("0.004"), // MONTH
    hre.ethers.utils.parseEther("0.05"), // YEAR
    hre.ethers.utils.parseEther("0.008"), // 2 MONTH
    hre.ethers.utils.parseEther("0.03"), // 6 MONTH
    hre.ethers.utils.parseEther("0.012"), // 3 MONTH
  ];

  const [owner] = await hre.ethers.getSigners();

  const subscriptionContractFactory = await hre.ethers.getContractFactory(
    "Subscription"
  );
  const subscriptionContract = await subscriptionContractFactory.deploy(prices);
  await subscriptionContract.deployed();
  console.log("Contract deployed to:", subscriptionContract.address);

  // subscribe
  let txn = await subscriptionContract.subscribe(1);
  await txn.wait();

  // show the subscriber
  let info = await subscriptionContract.getSubInfo(owner.address);
  console.log("Subscriber:", info);

  // show all subscribers
  let subs = await subscriptionContract.getAllSubscribers();
  console.log("All subscribers:", subs);

  // subscriber has tokens
  let subTokens = await subscriptionContract.balanceOf(owner.address, 0);
  console.log("Sub tokens:", subTokens.toString());
  let durationTokens = await subscriptionContract.balanceOf(owner.address, 1);
  console.log("Duration tokens:", durationTokens.toString());

  // cancel subscription
  txn = await subscriptionContract.cancel(owner.address);
  await txn.wait();

  // show the subscriber
  info = await subscriptionContract.getSubInfo(owner.address);
  console.log("Subscriber (cancelled):", info);

  // subscriber has tokens
  subTokens = await subscriptionContract.balanceOf(owner.address, 0);
  console.log("Sub tokens:", subTokens.toString());
  durationTokens = await subscriptionContract.balanceOf(owner.address, 1);
  console.log("Duration tokens:", durationTokens.toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
