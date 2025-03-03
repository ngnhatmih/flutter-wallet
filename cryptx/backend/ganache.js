const Ganache = require("ganache-cli");
const { Web3 } = require('web3');

const options = {
  port: 8545,
  network_id: 5777,
  total_accounts: 10,
  default_balance_ether: 100,
  gasLimit: 8000000,
  account_keys_path: 'test-accounts.json',
};

const ganache = Ganache.server(options);
ganache.listen(async (err) => {
  if (err) {
    console.error("Error starting Ganache:", err);
  } else {
    console.log(`Ganache running on http://127.0.0.1:${options.port}`);
    const accounts = ganache.getWallets();
    const web3 = new Web3(`http://127.0.0.1:${options.port}`);

    console.log("\nAvailable accounts");
    console.log("==================");


    
    // var index = 0;
    // for (const [address, privateKey] of Object.entries(accounts.private_keys)) {
    //   const balance = await web3.eth.getBalance(address) / BigInt(1e18);
    //   console.log(`[${index++}] ${address} (${balance} ETH)`);
    // }

    console.log("\n");
    
  }
});