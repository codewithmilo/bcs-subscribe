const { expect } = require("chai");

describe("Subscription", function () {
  let subscriptionContract, owner;

  beforeEach(async () => {
    [owner] = await hre.ethers.getSigners();
    const subscriptionContractFactory = await hre.ethers.getContractFactory(
      "Subscription"
    );
    subscriptionContract = await subscriptionContractFactory.deploy([
      1, 2, 3, 4, 5, 6, 7,
    ]);
    await subscriptionContract.deployed();
  });
  it("Should create a new subscriber", async function () {
    // free subscription
    let txn = await subscriptionContract.subscribe(1);
    await txn.wait();

    let info = await subscriptionContract.getSubInfo(owner.address);
    expect(info).to.have.property("duration").and.to.equal(1);
    expect(info).to.have.property("status").and.to.equal(0);

    let subs = await subscriptionContract.getAllSubscribers();
    expect(subs).to.have.lengthOf(1);
    expect(subs[0]).to.equal(owner.address);
  });
});
