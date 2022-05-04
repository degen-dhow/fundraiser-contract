'reach 0.1';

export const main = Reach.App(() => {
  const common = {
    timedOut: Fun([], Null),
  };
  const I = Participant('Initiator', {
    address: Address,
    duration: UInt,
    threshold: UInt,
    ...common,
  });
  const F = Participant('Funder', {
    shouldContribute: Bool,
    getContribution: Fun([], UInt),
    showContribution: Fun([UInt], Null),
    ...common,
  });
  const timedOut = () => {
    each([I, F], () => {
      interact.timedOut();
    });
  };
  init();

  I.only(() => {
    const address = declassify(interact.address);
    const duration = declassify(interact.duration);
    const threshold = declassify(interact.threshold);
  });
  I.publish(address, duration, threshold);
  commit();

  F.publish();

  const [ keepGoing, f, contributions ] =
  parallelReduce([ true, F, 0 ])
    .invariant(true)
    .while(keepGoing)
    .case(F,
      (() => ({
        when: declassify(interact.shouldContribute),
        msg: declassify(interact.getContribution())
      })),
      ((msg) => msg),
      ((msg) => {
        const funder = this;
        F.only(() => interact.showContribution(msg));
        return [ balance() < threshold, funder, contributions + 1 ];
      })
    )
    .timeout(relativeTime(duration), () => {
      F.publish();
      F.interact.timedOut();
      return [ false, f, contributions ];
    });

  transfer(balance()).to(address);
  commit();
  exit();
});
