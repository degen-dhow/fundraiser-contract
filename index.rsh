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
  commit();

  F.only(() => {
    const contribution = declassify(interact.getContribution());
  });

  F.publish(contribution)
  .pay(contribution)
  .timeout(relativeTime(duration), () => {
    closeTo(F, timedOut);
  });

  
  transfer(balance()).to(address);
  commit();
  exit();
});
