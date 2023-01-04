// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../utils/losslessEnv.t.sol";

contract RetrievedFundsClaim is LosslessTestEnvironment {

}
/* describe('when retrieving funds to proposed wallet', () => {
    it('should transfer funds', async () => {
      await env.lssGovernance.connect(adr.lssAdmin)
        .proposeWallet(1, adr.regularUser5.address);

      await ethers.provider.send('evm_increaseTime', [
        Number(time.duration.days(25)),
      ]);

      await expect(
        env.lssGovernance.connect(adr.regularUser5).retrieveFunds(1),
      ).to.not.be.reverted;

      expect(
        await lerc20Token.balanceOf(adr.regularUser5.address),
      ).to.be.equal(toRetrieve);
    });

    describe('when trying to retrieve two times', () => {
      it('should revert', async () => {
        await env.lssGovernance.connect(adr.lssAdmin)
          .proposeWallet(1, adr.regularUser5.address);

        await ethers.provider.send('evm_increaseTime', [
          Number(time.duration.days(8)),
        ]);

        await expect(
          env.lssGovernance.connect(adr.regularUser5).retrieveFunds(1),
        ).to.not.be.reverted;

        await expect(
          env.lssGovernance.connect(adr.regularUser5).retrieveFunds(1),
        ).to.be.revertedWith('LSS: Funds already claimed');
      });
    });

    describe('when non proposed wallet tries to claim', () => {
      it('should revert', async () => {
        await env.lssGovernance.connect(adr.lssAdmin)
          .proposeWallet(1, adr.regularUser5.address);

        await ethers.provider.send('evm_increaseTime', [
          Number(time.duration.days(8)),
        ]);

        await expect(
          env.lssGovernance.connect(adr.regularUser1).retrieveFunds(1),
        ).to.be.revertedWith('LSS: Only proposed adr can claim');
      });
    });
  });

  describe('when dispute period is not over', () => {
    it('should revert', async () => {
      await env.lssGovernance.connect(adr.lssAdmin)
        .proposeWallet(1, adr.regularUser5.address);

      await expect(
        env.lssGovernance.connect(adr.regularUser5).retrieveFunds(1),
      ).to.be.revertedWith('LSS: Dispute period not closed');
    });
  });

  describe('when the report does not exist', () => {
    it('should revert', async () => {
      await env.lssGovernance.connect(adr.lssAdmin)
        .proposeWallet(1, adr.regularUser5.address);

      await expect(
        env.lssGovernance.connect(adr.regularUser5).retrieveFunds(11),
      ).to.be.revertedWith('LSS: Report does not exist');
    });
  });
}); */
