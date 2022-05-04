import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);

const [ accInitiator, accFunder, accFunder2, fundee ] =
  await stdlib.newTestAccounts(4, startingBalance);
console.log('Launching four accounts');

console.log('Launching...');
const ctcInitiator = accInitiator.contract(backend);
const ctcInfo = ctcInitiator.getInfo();
const ctcFunder = accFunder.contract(backend, ctcInfo);

console.log('Starting backends...');
await Promise.all([
  backend.Initiator(ctcInitiator, {
    address: fundee.getAddress(),
    duration: 10,
    threshold: stdlib.parseCurrency(20),
    timedOut: () => console.log('timed out'),
  }),
  backend.Funder(ctcFunder, {
    shouldContribute: true,
    getContribution: async () => { 
      await stdlib.wait(0);
      return stdlib.parseCurrency(Math.random() * 100);
    },
    showContribution: (amt) => console.log(`funder 1 gave ${stdlib.bigNumberToNumber(amt)/1_000_000}`),
    timedOut: () => console.log('timed out'),
  })
]);

console.log(`${await stdlib.balanceOf(fundee)/1_000_000}`);
console.log('Goodbye!');
